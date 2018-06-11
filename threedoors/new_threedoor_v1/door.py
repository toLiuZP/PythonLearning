import random

class Doors(object):
    """def __init__(self, win_num):
        self.win_num = win_num"""

    def gen_award_door (self) -> None:
        self.award_door = random.randint(1, 3)