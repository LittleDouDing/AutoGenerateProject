def to_dict(self):
    result = {}
    for key in self.__mapper__.c.keys():
        if isinstance(getattr(self, key), (dict, list)):
            result[key] = getattr(self, key)
        else:
            if getattr(self, key) is not None:
                result[key] = str(getattr(self, key))
            else:
                result[key] = getattr(self, key)
    return result
