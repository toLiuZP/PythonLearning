from flask import Flask, render_template, request,redirect, escape
import vsearch
from DBcm import UseDataBase, DBConnectionError, CredentialsError, SQLError

app = Flask(__name__)
app.config['dbconfig'] = {'host': '127.0.0.1',
                            'user': 'vsearch',
                            'password':'test',
                            'database':'vsearchlogDB',
                            }


def log_request(req:'flask_request', res:str) -> None:
    """Log details of the web request and the results."""
    with UseDataBase(app.config['dbconfig']) as cursor:
        _SQL = """ insert into log
                    (phrase, letters, ip, browser_string, results) values (%s,%s,%s,%s,%s)"""
        cursor.execute(_SQL, (req.form['phrase'],
                                req.form['letters'],
                                req.remote_addr,
                                req.user_agent.browser,
                                res,))


@app.route('/search4', methods = ['POST'])
def do_search() -> 'html':
    phrase = request.form['phrase']
    letters = request.form['letters']
    title = 'Here are your results:'
    result = str(vsearch.search4letters(phrase,letters))
    log_request(request,result)
    return render_template('results.html',the_phrase=phrase,the_letters=letters,the_results=result,the_title=title,)


@app.route('/')
@app.route('/entry')
def entry_page() -> 'html':
    return render_template('entry.html', the_title = 'Welcome to search4letters on the web!')


@app.route('/viewlog')
def view_the_log() -> 'html':
    try:
        """Display the contents of the log file as a HTML table."""
        with UseDataBase(app.config['dbconfig']) as cursor:
            _SQL = """select phrase, letters, ip, browser_string, results from log"""
            cursor.execute(_SQL)
            contents = cursor.fetchall()

            titles = ('Phrase','Letters', 'Remote_addr','User_agent','Results')
            return render_template('viewlog.html',
                                    the_title='View Log',
                                    the_row_titles=titles,
                                    the_data=contents,)
    except DBConnectionError as err:
        print('Is your database swithed on? Error:', str(err))
    except CredentialsError as err:
        print('User-id/Password issues. Error:', str(err))
    except SQLError as err:
        print('Is your query correct? Error:',str(err))
    except Exception as err:
        print ('Something went wrong:', str(err))
    return "Error"
        

if __name__ == '__main__':
    app.run(debug=True) 