extends Reference
class_name Replay

const save_path: String = "user://replays/"
const debug_save_path: String = "res://replays/"
static func serialize_lifetime_history(history: Array) -> Array:
	var t1: int = OS.get_ticks_usec()
	var t2: int
	# could do this with multiple arrays but like idk ion really feel like it
	for idx in history.size():
		history[idx] = serialize_snapshot(history[idx])
	t2 = OS.get_ticks_usec()
	prints("serialization completed in ",t2-t1," microseconds")
	return history

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

static func replay_to_compressed_buffer(replay: Array) -> PoolByteArray:
	return var2str(replay).to_ascii().compress(File.COMPRESSION_GZIP)

static func decompress_data(file: File, end: int) -> PoolByteArray:
	return file.get_buffer(end).decompress_dynamic(-1,File.COMPRESSION_GZIP)

static func decompress_data_to_string(file: File, end: int) -> String:
	return decompress_data(file, end).get_string_from_ascii()

static func read_compressed_replay_file(filepath: String) -> Array:
	var file := File.new()
	print("reading compressed replay file...")
	if file.open(filepath, File.READ) == OK:
		return open_compressed(file)
	else:
		print("error reading compressed replay file!")
		return []

static func open_compressed(file: File) -> Array:
	print("opening compressed replay file")
	file.seek_end()
	var end := file.get_position()
	assert(end == file.get_len())
	file.seek(0)
	print("decompressing replay file...")
	var replay = str2var(decompress_data_to_string(file,end))
	print("data successfully decompressed!")
	assert(replay is Array)
	return replay

static func get_file_name(title: String) -> String:
	return str("%s %s %s.REPLAY"%[title, Quack.datetime_string(), OS.get_unique_id()])

static func file_path_debug(name: String) -> String:
	return debug_save_path + name

static func file_path_normal(name: String) -> String:
	return save_path + name

static func save_compressed(file: File, replay: Array, title: String) -> void:
	if !Quack.is_exported():
		file.open(file_path_debug(get_file_name(title)), File.WRITE)
	else:
		file.open(file_path_normal(get_file_name(title)), File.WRITE)
	print("storing compressed replay file...")
	file.store_buffer(replay_to_compressed_buffer(replay))
	
	print("closing compressed replay file...")
	print(get_file_name(title))
	file.close()

static func save(replay: Array) -> void:
	save_compressed(File.new(),serialize_lifetime_history(replay),"replay")
