import random

class Player(object):

    def make_choose(self):
        self.choose = random.randint(1, 3)

    def change_choose(self, award_door:int) -> None:
        keep_try_ind = True
        while keep_try_ind:
            deserted_choose = random.randint(1, 3)
            if self.choose != deserted_choose and award_door != deserted_choose :
                keep_try_ind = False
                new_match_ind = True
                while new_match_ind:
                    self.new_choose = random.randint(1, 3)
                    if deserted_choose != self.new_choose:
                        new_match_ind = False
