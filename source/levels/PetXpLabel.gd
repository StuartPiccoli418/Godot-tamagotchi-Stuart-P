extends Label

func update_label(level, experience, required_exp):
	text="""Level: %s
	Experience: %s
	Next level: %s
	""" % [level, experience, required_exp]
