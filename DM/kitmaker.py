import pathlib
from datetime import datetime

# This is a simple module for generating a single database release script
# from a set of individual DDL scripts.  

HEADER = """\
--==============================================================================
-- RELEASE FILE: {0}
-- GENERATED: {1}
--==============================================================================
"""

USEDB = """\

--------------------------------------------------------------------------------
PRINT '[INFO] USING DB {0}'
USE {0}
GO
"""

STARTFILE = """\

--------------------------------------------------------------------------------
-- START: {0}

"""

ENDFILE = """\

GO
-- END: {0}
--------------------------------------------------------------------------------
"""

class Release( object ):

    def __init__( self, release_file, *plans ):
        # first argument must be the output file name
        # all subsequent arguments must be Plan objects
        self.release_file = release_file
        self.plans = plans

    def generate( self ):
        #generates the release script using the specified plans
        with open( self.release_file, 'w' ) as outfile:
            outfile.write( HEADER.format( self.release_file, datetime.today() ) )
            for plan in self.plans:
                outfile.write( USEDB.format( plan.keyword_dict['DBNAME'] ) )
                for path in plan:
                    *parts, ftype, fname = path.parts
                    outfile.write( STARTFILE.format( fname ) )
                    with path.open() as infile:
                        for line in infile:
                            outfile.write( line.format_map( plan.keyword_dict ) )
                    outfile.write( ENDFILE.format( fname ) )

class Plan( object ):

    def __init__( self, keyword_dict, *paths ):
        # first argument must be a dict of keys and values to replace
        # in the source scripts and must contain at least DBNAME.  all
        # subsequent arguments are treated as paths to folders or files
        # which should be included in the output
        self.keyword_dict = keyword_dict
        self.paths = paths

    def __iter__( self ):
        for p in self.paths:
            path = pathlib.Path( p )
            if path.is_dir():
                yield from path.iterdir()
            else:
                yield path
        
