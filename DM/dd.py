import kitmaker

kitmaker.Release(
    r'D:\Work\07. Git\insights-sql\Deployment\Task\R3 Initial\R3.sql',
    kitmaker.Plan(
        dict(
            DBNAME='AO_SALES_MART',
            TABLEFG='AO_SALES_MART_DATA',
            INDEXFG='AO_SALES_MART_IDX'
        ),
        r'D:\Work\07. Git\insights-sql\SourceCode\Databases\AO_R3\Tables'
    )
).generate()
