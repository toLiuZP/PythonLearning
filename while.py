number = 23
running = True # we can use 1
while running:
    guess = int(input('Enter an integer : '))
    if guess == number:
        print('Congratulations, you guessed it.')
        # 这将导致 while 循环中止
        running = False # we can use 0 here
    elif guess < number:
        print('No, it is a little higher than that.')
    else:
        print('No, it is a little lower than that.')
else:
        print('The while loop is over.')
# 在这里你可以做你想做的任何事
print('Done')
