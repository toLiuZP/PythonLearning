import random

class Player(object):
    """def __init__(self,choose,new_choose):
        self.choose = choose
        self.new_choose = new_choose"""

    def make_choose(self):
        self.choose = random.randint(1, 3)

    def change_choose(self, award_door:int) -> None:
        keep_try_ind = True
        while keep_try_ind:
            next_choose = random.randint(1, 3)
            if self.choose != next_choose and award_door != next_choose :
                keep_try_ind = False
                # self.choose = next_choose
                self.new_choose = next_choose
                """new_match_ind = True
                while new_match_ind:
                    self.new_choose = random.randint(1, 3)
                    if next_choose <> self.new_choose:
                        new_match_ind = False"""
