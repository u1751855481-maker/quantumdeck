extends Node

enum State {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

signal state_changed(new_state: State)

var current_state: State = State.MENU

func set_state(new_state: State) -> void:
	if(current_state == new_state):
		return
	current_state = new_state
	state_changed.emit(current_state)

func can_pause() -> bool:
	return current_state == State.PLAYING or current_state == State.PAUSED

func is_game_over() -> bool:
	return current_state == State.GAME_OVER
