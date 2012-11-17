# circle.py
import math

class circle:
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return math.pi * self.radius**2

    def perimeter(self):
        return 2 * math.pi * self.radius


if __name__ == '__main__':
    c1 = circle(1.0)

    print 'area: ', c1.area()
    print 'perimeter: ', c1.perimeter()
