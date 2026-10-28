def _field_matches(field, value):
    if field == "*":
        return True
    return value in {int(part) for part in field.split(",")}


def matches(expression, local):
    minute, hour, day, month, weekday = expression.split()
    return (
        _field_matches(minute, local.minute)
        and _field_matches(hour, local.hour)
        and _field_matches(day, local.day)
        and _field_matches(month, local.month)
        and _field_matches(weekday, local.isoweekday() % 7)
    )
