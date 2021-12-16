import math
from typing import Match


BOARD_MAX_X = 16000
BOARD_MAX_Y = 9000
ZOMBIE_SPEED = 400
ASH_SPEED = 1000
GUN_RADIUS = 2000


class Parent:
    def __init__(self, x, y, id):
        self.x = x
        self.y = y
        self.id = id

    def distanceFromPoint(self, pointX, pointY):
        sum_of_squares = (pointX - self.x)**2 + (pointY - self.y)**2
        return math.sqrt(sum_of_squares)

    def to_s(self):
        return f'{self.x}, {self.y}, {self.id}'


class Human(Parent):
    pass


class Zombie(Parent):
    def move(self):
        # not sure how to translate those func
        nextMoveX = self.x
        nextMoveY = self.y
        return [self.x, self.y]


class Ash(Parent):
    pass


class Game(Parent):
    pass
