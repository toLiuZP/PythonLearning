import random

class Doors(object):

    def gen_award_door (self) -> None:
        self.award_door = random.randint(1, 3)