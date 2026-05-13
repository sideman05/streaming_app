USE iptv_app;

-- Custom channels seed requested by user.
-- This file uses legal placeholder stream URLs by default.
-- Replace stream_url values with your licensed provider links when authorized.

INSERT INTO channels (
  category_id,
  name,
  logo_url,
  stream_url,
  description,
  is_premium,
  status
)
SELECT
  c.id,
  t.name,
  t.logo_url,
  t.stream_url,
  t.description,
  t.is_premium,
  1
FROM (
  SELECT 'Entertainment' AS category_name, 'Wasafi TV' AS name,
         'https://ui-avatars.com/api/?name=Wasafi+TV&background=1f2937&color=ffffff&size=256' AS logo_url,
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8' AS stream_url,
         'Entertainment and lifestyle content.' AS description,
         0 AS is_premium

  UNION ALL SELECT 'Movies', 'Sinema Zetu',
         'https://ui-avatars.com/api/?name=Sinema+Zetu&background=1f2937&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Movies and local cinema content.',
         0

  UNION ALL SELECT 'Sports', 'Azam Sport 1',
         'https://ui-avatars.com/api/?name=Azam+Sport+1&background=0b3a6a&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Live sports channel 1.',
         1

  UNION ALL SELECT 'Sports', 'Azam Sport 2',
         'https://ui-avatars.com/api/?name=Azam+Sport+2&background=0b3a6a&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Live sports channel 2.',
         1

  UNION ALL SELECT 'Sports', 'Azam Sport 3',
         'https://ui-avatars.com/api/?name=Azam+Sport+3&background=0b3a6a&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Live sports channel 3.',
         1

  UNION ALL SELECT 'Sports', 'Azam Sport 4',
         'https://ui-avatars.com/api/?name=Azam+Sport+4&background=0b3a6a&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Live sports channel 4.',
         1

  UNION ALL SELECT 'Entertainment', 'Cheka Plus',
         'https://ui-avatars.com/api/?name=Cheka+Plus&background=1f2937&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Entertainment variety channel.',
         0

  UNION ALL SELECT 'Entertainment', 'Zamaradi TV',
         'https://ui-avatars.com/api/?name=Zamaradi+TV&background=1f2937&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'General entertainment and lifestyle.',
         0

  UNION ALL SELECT 'Sports', 'Other Sports',
         'https://ui-avatars.com/api/?name=Other+Sports&background=0b3a6a&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Additional sports feed.',
         0

  UNION ALL SELECT 'Entertainment', 'Abood TV',
         'https://ui-avatars.com/api/?name=Abood+TV&background=1f2937&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'General entertainment channel.',
         0

  UNION ALL SELECT 'Sports', 'Bein Sports',
         'https://ui-avatars.com/api/?name=Bein+Sports&background=0b3a6a&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'International sports channel.',
         1

  UNION ALL SELECT 'News', 'BBC',
         'https://ui-avatars.com/api/?name=BBC&background=374151&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Global news and features.',
         0

  UNION ALL SELECT 'News', 'CNN',
         'https://ui-avatars.com/api/?name=CNN&background=374151&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Breaking news and world coverage.',
         0

  UNION ALL SELECT 'Movies', 'Horizon Movies',
         'https://ui-avatars.com/api/?name=Horizon+Movies&background=111827&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Movies and cinematic shows.',
         0

  UNION ALL SELECT 'Sports', 'WWE',
         'https://ui-avatars.com/api/?name=WWE&background=0b3a6a&color=ffffff&size=256',
         'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
         'Wrestling and combat entertainment.',
         1
) AS t
JOIN categories c ON c.name = t.category_name;
