from spellchecker import SpellChecker


column_name = 'TST_KEY'
incorrect_ind = False
new_column_name = ''

spell = SpellChecker()

test = spell.split_words(column_name.replace('_',' '))
for word in test:
    if not spell.unknown(word):
        incorrect_ind = True
        new_column_name += spell.correction(word) + ' '
    else:
        new_column_name += word + ' '
    print(new_column_name.replace(' ','_'))