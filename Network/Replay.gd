extends Reference
class_name Replay

static func serialize_lifetime_history(history: Array) -> void:
	var t1: int = OS.get_ticks_usec()
	var t2: int
	# could do this with multiple arrays but like idk ion really feel like it
	for idx in history.size():
		history[idx] = serialize_snapshot(history[idx])
	t2 = OS.get_ticks_usec()
	prints("serialization completed in ",t2-t1," microseconds")

enum {SIGNATURE,INPUT_SIG,ENTITY_DATA}
static func serialize_snapshot(snapshot: NetSnapshot) -> Array:
	var serialized_snapshot: Array = [snapshot.signature,snapshot.input_sig,{}]
	var serialized_entity_data: Dictionary = serialized_snapshot[ENTITY_DATA]
	var entity_data: Dictionary = snapshot._entity_data
	for nhash in entity_data.keys():
		var serialized_entities: Dictionary = {}
		serialized_entity_data[nhash] = serialized_entities
		for entity_id in entity_data[nhash].keys():
			pass
#			serialized_entities[entity_id] = 
		assert(serialized_entity_data.hash() == serialized_snapshot[ENTITY_DATA].hash())
	return serialized_snapshot

static func serialize_entity(entity: SnapEntityBase) -> Array:
	var serialized_entity: Array
	for property in entity.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			serialized_entity.append(entity[property.name])
	return serialized_entity
