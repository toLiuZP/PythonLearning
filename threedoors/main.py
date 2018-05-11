import random
#import Output_file


class Doors(object):
    def __init__(self, win_num):
        self.win_num = win_num
    def win_choose (self):
        self.win_num = random.randint(1, 3)

    def get_win_num(self):
        return self.win_num

class Player(object):
    def __init__(self,choose,new_choose):
        self.choose = choose
        self.new_choose = new_choose
    def make_choose(self):
        self.choose = random.randint(1, 3)


    def change_choose(self, win_num):
        match_ind = True
        while match_ind:
            next_choose = random.randint(1, 3)
            if self.choose <> next_choose and win_num <> next_choose:
                match_ind = False
                # self.choose = next_choose
                new_match_ind = True
                while new_match_ind:
                    self.new_choose = random.randint(1, 3)
                    if next_choose <> self.new_choose:
                        new_match_ind = False

    def get_new_choose(self):
        return self.new_choose

    def get_choose(self):
        return self.choose

if __name__ == '__main__':
    running = True
    win = 0
    lose = 0
    counter = 0
    while running:
        LuckDoor = Doors('0')
        PlayerA = Player('0','0')

        LuckDoor.win_choose()
        PlayerA.make_choose()

        #if LuckDoor.get_win_num() <> PlayerA.get_choose():
            # print LuckDoor.get_win_num()

        PlayerA.change_choose(LuckDoor.get_win_num())

        if PlayerA.get_choose() <> PlayerA.get_new_choose():
            print('The prize is behind the {} door.'.format(LuckDoor.get_win_num()))
            print('Player chose the ' + str(PlayerA.get_choose()) + ' door at the begining.')

            print('Player changing their chose now')
            print('Player''s new choose is ' + str(PlayerA.get_new_choose()) + ' door.\n')
            counter = counter + 1
            if counter == 1000:
                running = False

            if LuckDoor.get_win_num() == PlayerA.get_new_choose():
                win = win +1
            else:
                lose = lose +1
    print('After change, player wins ' + str(win) + ' times')
    print('After change, player lose ' + str(lose) + ' times')
