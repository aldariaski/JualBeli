USE JualBeliDb;

SELECT 
    c.TABLE_SCHEMA AS table_schema,
    c.TABLE_NAME AS table_name,
    c.ORDINAL_POSITION AS ordinal_position,
    c.COLUMN_NAME AS column_name,
    c.DATA_TYPE AS data_type,

    -- Character / binary length
    c.CHARACTER_MAXIMUM_LENGTH AS max_length,

    -- Numeric properties
    c.NUMERIC_PRECISION AS numeric_precision,
    c.NUMERIC_SCALE AS numeric_scale,

    -- Date/time precision
    c.DATETIME_PRECISION AS datetime_precision,

    -- NULL / NOT NULL
    c.IS_NULLABLE AS is_nullable,

    -- Default value
    c.COLUMN_DEFAULT AS column_default,

    -- Identity
    CASE 
        WHEN COLUMNPROPERTY(
            OBJECT_ID(
                QUOTENAME(c.TABLE_SCHEMA) + '.' + QUOTENAME(c.TABLE_NAME)
            ),
            c.COLUMN_NAME,
            'IsIdentity'
        ) = 1
        THEN 'YES'
        ELSE 'NO'
    END AS is_identity,

    -- Primary key
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
            INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                ON kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
                AND kcu.TABLE_SCHEMA = tc.TABLE_SCHEMA
                AND kcu.TABLE_NAME = tc.TABLE_NAME
            WHERE 
                tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                AND kcu.TABLE_SCHEMA = c.TABLE_SCHEMA
                AND kcu.TABLE_NAME = c.TABLE_NAME
                AND kcu.COLUMN_NAME = c.COLUMN_NAME
        )
        THEN 'YES'
        ELSE 'NO'
    END AS is_primary_key

FROM INFORMATION_SCHEMA.COLUMNS c

WHERE 
    c.TABLE_SCHEMA NOT IN (
        'information_schema',
        'pg_catalog'
    )

ORDER BY 
    c.TABLE_SCHEMA,
    c.TABLE_NAME,
    c.ORDINAL_POSITION;