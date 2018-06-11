import door
import player

running = True
win_times = 0
lose_times = 0
counter = 0
while running:
    luckydoor = Doors()
    playera = Player()

    luckydoor.gen_award_door()
    playera.make_choose()
    playera.change_choose(luckydoor.award_door)

    if playera.choose != playera.new_choose:
        print('The prize is behind the {} door.'.format(luckydoor.award_door))
        print('Player chose the {} door at the begining.'.format(playera.choose))
        print('Player changing their chose now')
        print('Player''s new choose is ' + playera.new_choose + ' door.')
        counter = counter + 1
        if counter == 1000:
            running = False

        if luckydoor.award_door == playera.new_choose:
            win = win_times +1
        else:
            lose = lose_times +1
print('After change, player wins ' + win_times + ' times')
print('After change, player lose ' + lose_times + ' times')
