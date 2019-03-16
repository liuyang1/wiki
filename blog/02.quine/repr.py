class Ridiculous:
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return "Ridiculous('%s')" % (self.name)

    def __str__(self):
        return "%s is ridiculous" % (self.name)

god = Ridiculous('god')
print god

print repr(god)
print eval(repr(god))
