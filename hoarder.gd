extends Node

var _THEYRE_MINE_YOU_CANT_HAVE_THEM: Array[Resource] = []

func keep_loaded(res: Resource):
	res.reference()
	_THEYRE_MINE_YOU_CANT_HAVE_THEM.append(res)
