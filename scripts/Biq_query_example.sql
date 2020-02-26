SELECT DISTINCT s, COUNT(s) c
FROM (
  SELECT SPLIT(REGEXP_REPLACE(REGEXP_REPLACE(url, r'https?:\/\/([-a-zA-Z0-9@:%._\+~#=]{0,256}\.)([-a-zA-Z0-9@:%._\+~#=]{1,256}){1}\.([a-zA-Z]{1,6})', '\\1'), r'https?:\/\/.*', ''), '.') subd
  FROM (
    SELECT DISTINCT url
    FROM `bigquery-public-data.github_repos.contents` 
    CROSS JOIN UNNEST(REGEXP_EXTRACT_ALL(LOWER(content), r'https?:\/\/[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z]{1,6}')) AS url
)
)
CROSS JOIN UNNEST(subd) as s
WHERE s != '' and s not like '%@%'
GROUP BY s
ORDER BY c DESC
