extends Reference
class_name Replay

const save_path: String = "user://replays/"
const debug_save_path: String = "res://replays/"

static func replay_to_compressed_buffer(replay: Array) -> PoolByteArray:
	return var2str(replay).to_ascii().compress(File.COMPRESSION_GZIP)

static func decompress_data(file: File, end: int) -> PoolByteArray:
	return file.get_buffer(end).decompress_dynamic(-1,File.COMPRESSION_GZIP)

static func decompress_data_to_string(file: File, end: int) -> String:
	return decompress_data(file, end).get_string_from_ascii()

static func read_compressed_replay_file(filepath: String) -> Array:
	var file := File.new()
	Console.write("reading compressed replay file...")
	if file.open(filepath, File.READ) == OK:
		return open_compressed(file)
	else:
		Console.write("error reading compressed replay file!")
		return []

static func open_compressed(file: File) -> Array:
	Console.write("opening compressed replay file")
	file.seek_end()
	var end := file.get_position()
	assert(end == file.get_len())
	file.seek(0)
	Console.write("decompressing replay file...")
	var replay = str2var(decompress_data_to_string(file,end))
	Console.write("data successfully decompressed!")
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
	Console.write("storing compressed replay file...")
	file.store_buffer(replay_to_compressed_buffer(replay))
	
	Console.write("closing compressed replay file...")
	Console.write(get_file_name(title))
	file.close()

static func save(replay: Array) -> void:
	save_compressed(File.new(),replay,"replay")
