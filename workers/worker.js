// Настройки тестовой версии.
// Попытки учитываются даже при ошибке ответа OpenAI.
const GLOBAL_DAILY_LIMIT = 30;
const MAX_BODY_BYTES = 16000;
const MAX_PROMPT_CHARS = 6000;
const GOOGLE_KEYS_URL =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';
let keyCache = { keys: [], expires: 0 };
let keyFetch = null;
class HttpError extends Error {
  constructor(status, code) {
super(code);
this.status = status;
  }
}
function json(value, status = 200) {
  return new Response(JSON.stringify(value), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
    },
  });
}
function decode64url(value) {
  if (!/^[A-Za-z0-9_-]+$/.test(value)) {
    throw new Error('Invalid base64url');
  }
  const base = value.replace(/-/g, '+').replace(/_/g, '/');
  return Uint8Array.from(
    atob(base + '='.repeat((4 - base.length % 4) % 4)),
    c => c.charCodeAt(0),
  );
}
function decodePart(value) {
  return JSON.parse(
    new TextDecoder('utf-8', { fatal: true, ignoreBOM: false })
      .decode(decode64url(value)),
  );
}
// Публичные ключи Google для проверки подписи токена Firebase.
async function googleKeys() {
  if (keyCache.expires > Date.now()) {
    return keyCache.keys;
  }
  if (!keyFetch) {
    keyFetch = (async () => {
      try {
        const response = await fetch(GOOGLE_KEYS_URL, {
          signal: AbortSignal.timeout(10000),
        });
        if (!response.ok) {
          throw new Error('Key service unavailable');
        }
        const data = await response.json();
        if (!Array.isArray(data.keys) || !data.keys.length) {
          throw new Error('Missing keys');
        }
        const age = Number(
          (response.headers.get('cache-control') || '')
            .match(/max-age=(\d+)/)?.[1] || 300,
        );
        keyCache = {
          keys: data.keys,
          expires: Date.now() + Math.min(age, 86400) * 1000,
        };
        return keyCache.keys;
      } catch {
        throw new HttpError(503, 'AUTH_SERVICE_UNAVAILABLE');
      } finally {
        keyFetch = null;
      }
    })();
  }
  return keyFetch;
}
// Проверяем не просто UID, а подписанный Firebase ID token.
async function verifyUser(request, projectId) {
  const authorization =
    request.headers.get('Authorization') || '';
  if (authorization.length > 12000) {
    throw new HttpError(401, 'INVALID_TOKEN');
  }
  const match = authorization.match(
    /^Bearer ([A-Za-z0-9_.-]+)$/i,
  );
  if (!match) {
    throw new HttpError(401, 'SIGN_IN_REQUIRED');
  }
  const parts = match[1].split('.');
  let header;
  let claims;
  try {
    if (parts.length !== 3) {
      throw new Error();
    }
    header = decodePart(parts[0]);
    claims = decodePart(parts[1]);
    const now = Math.floor(Date.now() / 1000);
    if (
      !header ||
      !claims ||
      header.alg !== 'RS256' ||
      typeof header.kid !== 'string' ||
      header.crit !== undefined ||
      header.kid.length > 200 ||
      claims.aud !== projectId ||
      claims.iss !== `https://securetoken.google.com/${projectId}` ||
      typeof claims.sub !== 'string' ||
      !claims.sub.length ||
      claims.sub.length > 128 ||
      !Number.isInteger(claims.exp) ||
      claims.exp <= now ||
      !Number.isInteger(claims.iat) ||
      claims.iat > now ||
      claims.iat < 0 ||
      !Number.isInteger(claims.auth_time) ||
      claims.auth_time > now ||
      claims.auth_time < 0 ||
      (
        claims.nbf !== undefined &&
        (
          !Number.isInteger(claims.nbf) ||
          claims.nbf > now
        )
      )
    ) {
      throw new Error();
    }
  } catch {
    throw new HttpError(401, 'INVALID_TOKEN');
  }
  const keys = await googleKeys();
  const jwk = keys.find(
    k =>
      k.kid === header.kid &&
      k.kty === 'RSA' &&
      k.alg === 'RS256',
  );
  if (!jwk) {
    throw new HttpError(401, 'INVALID_TOKEN');
  }
  try {
    const key = await crypto.subtle.importKey(
      'jwk',
      jwk,
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256',
      },
      false,
      ['verify'],
    );
    const valid = await crypto.subtle.verify(
      'RSASSA-PKCS1-v1_5',
      key,
      decode64url(parts[2]),
      new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
    );
    if (!valid) {
      throw new Error();
    }
  } catch {
    throw new HttpError(401, 'INVALID_TOKEN');
  }
  return claims.sub;
}
// Ограничиваем размер входящего запроса.
async function readInput(request, activation = false) {
  const type = (request.headers.get('content-type') || '')
    .split(';')[0]
    .trim()
    .toLowerCase();
  if (type !== 'application/json') {
    throw new HttpError(415, 'JSON_REQUIRED');
  }
  if (!request.body) {
    throw new HttpError(400, 'EMPTY_BODY');
  }
  const reader = request.body.getReader();
  const chunks = [];
  let size = 0;
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    size += value.length;
    if (size > MAX_BODY_BYTES) {
      await reader.cancel();
      throw new HttpError(413, 'BODY_TOO_LARGE');
    }
    chunks.push(value);
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.length;
  }
  let data;
  try {
    data = JSON.parse(
      new TextDecoder('utf-8', { fatal: true, ignoreBOM: false }).decode(bytes),
    );
  } catch {
    throw new HttpError(400, 'INVALID_JSON');
  }
  if (activation) {
    if (!data || typeof data.code !== 'string' || data.code.length > 100) {
      throw new HttpError(400, 'INVITE_INVALID');
    }
    const code = data.code.replace(/[\s-]/g, '').toUpperCase();
    if (!/^[A-F0-9]{32}$/.test(code)) {
      throw new HttpError(400, 'INVITE_INVALID');
    }
    return code;
  }
  if (
    !data ||
    typeof data.prompt !== 'string' ||
    !data.prompt.trim() ||
    data.prompt.length > MAX_PROMPT_CHARS
  ) {
    throw new HttpError(400, 'INVALID_PROMPT');
  }
  return data.prompt.trim();
}
// Значение -1 намеренно нарушает CHECK (request_count >= 0).
// При исчерпании лимита вся транзакция откатывается:
// либо увеличатся оба счётчика, либо ни один.
const GLOBAL_SQL = `
  INSERT INTO global_daily_usage (
    usage_date,
    request_count
  )
  VALUES (?, 1)
  ON CONFLICT(usage_date) DO UPDATE SET
    request_count =
      CASE
        WHEN request_count < ? THEN request_count + 1
        ELSE -1
      END
  RETURNING request_count
`;
const USER_SQL = `
  INSERT INTO daily_usage (
    uid,
    usage_date,
    request_count
  )
  VALUES (
    ?,
    ?,
    CASE
      WHEN COALESCE(
        (
          SELECT daily_limit
          FROM testers
          WHERE uid = ? AND enabled = 1
        ),
        0
      ) > 0 THEN 1
      ELSE -1
    END
  )
  ON CONFLICT(uid, usage_date) DO UPDATE SET
    request_count =
      CASE
        WHEN daily_usage.request_count < COALESCE(
          (
            SELECT daily_limit
            FROM testers
            WHERE uid = ? AND enabled = 1
          ),
          0
        )
        THEN daily_usage.request_count + 1
        ELSE -1
      END
  RETURNING request_count
`;
async function reserveAttempt(db, uid, day) {
  try {
    const results = await db.batch([
      db.prepare(GLOBAL_SQL).bind(day, GLOBAL_DAILY_LIMIT),
      db.prepare(USER_SQL).bind(uid, day, uid, uid),
    ]);
    if (results.some(r => !r.success)) {
      throw new Error('Database batch failed');
    }
    return results[1].results[0].request_count;
  } catch (error) {
    const details =
      `${error.message || ''} ${error.cause?.message || ''}`;
    if (/CHECK constraint failed/i.test(details)) {
      throw new HttpError(429, 'DAILY_LIMIT_REACHED');
    }
    throw error;
  }
}
const RECIPE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    recipe_name: {
      type: 'string',
    },
    shopping_list: {
      type: 'array',
      items: { type: 'string' },
    },
    steps: {
      type: 'array',
      items: { type: 'string' },
    },
  },
  required: ['recipe_name', 'shopping_list', 'steps'],
};
function validRecipe(value) {
  return (
    value &&
    typeof value.recipe_name === 'string' &&
    value.recipe_name.trim() &&
    Array.isArray(value.shopping_list) &&
    value.shopping_list.every(x => typeof x === 'string') &&
    Array.isArray(value.steps) &&
    value.steps.length > 0 &&
    value.steps.every(x => typeof x === 'string')
  );
}
// Ключ используется только здесь, на сервере.
async function generateRecipe(prompt, apiKey) {
  try {
    const response = await fetch(
      'https://api.openai.com/v1/chat/completions',
      {
        method: 'POST',
        signal: AbortSignal.timeout(45000),
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          temperature: 0.7,
          max_completion_tokens: 1500,
          response_format: {
            type: 'json_schema',
            json_schema: {
              name: 'recipe',
              strict: true,
              schema: RECIPE_SCHEMA,
            },
          },
          messages: [
            {
              role: 'system',
              content:
                'You are ZeroWasteChef. Return one recipe in the requested language. ' +
                'Follow the requested diet and portions. Only answer cooking requests. ' +
                'Exclude ingredients marked expired or spoiled. Never claim cooking makes spoiled food safe. ' +
                'Return recipe_name, shopping_list and steps using the supplied JSON schema.',
            },
            {
              role: 'user',
              content: prompt,
            },
          ],
        }),
      },
    );
    if (!response.ok) {
      await response.body?.cancel();
      throw new HttpError(502, 'AI_REQUEST_FAILED');
    }
    const data = await response.json();
    const choice = data.choices?.[0];
    if (
      choice?.finish_reason !== 'stop' ||
      choice.message?.refusal ||
      typeof choice.message?.content !== 'string'
    ) {
      throw new HttpError(502, 'AI_RESPONSE_INVALID');
    }
    const recipe = JSON.parse(choice.message.content);
    if (!validRecipe(recipe)) {
      throw new HttpError(502, 'AI_RESPONSE_INVALID');
    }
    return recipe;
  } catch (error) {
    if (error instanceof HttpError) throw error;
    throw new HttpError(502, 'AI_UNAVAILABLE');
  }
}
// Activation uses the verified Firebase UID, never a UID supplied in JSON.
async function activate(request, db, uid) {
  const existing = await db.prepare(
    'SELECT enabled FROM testers WHERE uid = ?',
  ).bind(uid).first();
  if (existing) {
    if (existing.enabled !== 1) throw new HttpError(403, 'TESTER_DISABLED');
    return json({ activated: true });
  }

  // At most 10 attempts per authenticated UID per 15-minute UTC window.
  // One row per UID; repeated calls do not grow the table without bound.
  const window = Math.floor(Date.now() / 900000);
  const attempt = await db.prepare(`
    INSERT INTO invite_attempts(uid, window_id, attempts) VALUES (?, ?, 1)
    ON CONFLICT(uid) DO UPDATE SET
      attempts = CASE WHEN window_id = excluded.window_id THEN attempts + 1 ELSE 1 END,
      window_id = excluded.window_id
    WHERE window_id <> excluded.window_id OR attempts < 10
    RETURNING attempts
  `).bind(uid, window).first();
  if (!attempt) throw new HttpError(429, 'INVITE_RATE_LIMITED');

  const code = await readInput(request, true);
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(code));
  const hash = Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2, '0')).join('');
  try {
    // The SQL triggers validate capacity and grant access in this same statement.
    // A concurrent retry for an existing tester inserts nothing and spends nothing.
    await db.prepare(`
      INSERT INTO invite_redemptions(uid, code_hash)
      SELECT ?, ? WHERE NOT EXISTS (SELECT 1 FROM testers WHERE uid = ?)
    `).bind(uid, hash, uid).run();
  } catch (error) {
    const details = `${error.message || ''} ${error.cause?.message || ''}`;
    if (details.includes('INVITE_UNAVAILABLE')) {
      throw new HttpError(400, 'INVITE_UNAVAILABLE');
    }
    throw error;
  }
  const tester = await db.prepare('SELECT enabled FROM testers WHERE uid = ?').bind(uid).first();
  if (!tester || tester.enabled !== 1) throw new HttpError(403, 'TESTER_DISABLED');
  return json({ activated: true });
}

export default {
  async fetch(request, env) {
    try {
      const path = new URL(request.url).pathname;
// Проверка доступности сервера без обращения к OpenAI.
      if (request.method === 'GET' && path === '/') {
        return json({
          status: 'ok',
          service: 'ZeroWasteChef API',
        });
      }
      if (!['/generate', '/quota', '/activate'].includes(path)) {
        return json({ error: 'NOT_FOUND' }, 404);
      }
      const expectedMethod =
        path === '/quota' ? 'GET' : 'POST';
      if (request.method !== expectedMethod) {
        return json({ error: 'METHOD_NOT_ALLOWED' }, 405);
      }
      if (
        !env.DB ||
        !env.FIREBASE_PROJECT_ID ||
        !env.OPENAI_API_KEY
      ) {
        throw new HttpError(503, 'SERVER_NOT_CONFIGURED');
      }
      const uid = await verifyUser(
        request,
        env.FIREBASE_PROJECT_ID,
      );
      const db = env.DB.withSession('first-primary');
    if (path === '/activate') return await activate(request, db, uid);
      const tester = await db.prepare(
        'SELECT enabled, daily_limit FROM testers WHERE uid = ?',
      ).bind(uid).first();
      if (!tester) throw new HttpError(403, 'TESTER_ACCESS_REQUIRED');
      if (tester.enabled !== 1) throw new HttpError(403, 'TESTER_DISABLED');
// Получение оставшегося лимита.
      if (path === '/quota') {
        const day = new Date().toISOString().slice(0, 10);
        const usage = await db.prepare(
          'SELECT request_count FROM daily_usage WHERE uid = ? AND usage_date = ?',
        ).bind(uid, day).first();
        const global = await db.prepare(
          'SELECT request_count FROM global_daily_usage WHERE usage_date = ?',
        ).bind(day).first();
        return json({
          date: day,
          timezone: 'UTC',
          limit: tester.daily_limit,
          remaining: Math.max(
            0,
            tester.daily_limit - (usage?.request_count || 0),
          ),
          group_available:
            (global?.request_count || 0) < GLOBAL_DAILY_LIMIT,
        });
      }
// Генерация рецепта.
      const prompt = await readInput(request);
      const day = new Date().toISOString().slice(0, 10);
      const used = await reserveAttempt(db, uid, day);
      const recipe = await generateRecipe(
        prompt,
        env.OPENAI_API_KEY,
      );
      return json({
        recipe,
        remaining: Math.max(0, tester.daily_limit - used),
        limit: tester.daily_limit,
        date: day,
      });
    } catch (error) {
      if (error instanceof HttpError) {
        return json({ error: error.message }, error.status);
      }
// Не выводим ключи, токены и содержимое запросов в журнал.
      console.error('ZeroWasteChef: internal request failure');
      return json({ error: 'SERVER_ERROR' }, 500);
    }
  },
};