-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). Для выгрузки в XML
-- проверить все режимы конструкции FOR XML

\t \a \o '/root/bmstu-db/src/lab5/json/Constellations.json'
    select array_to_json(array_agg(row_to_json(t))) as "Constellations"
    from Stars.Constellations as t;
\o
