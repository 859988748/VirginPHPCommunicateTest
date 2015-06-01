<?php
	function lock($msg)
	{
		file_put_contents('./lock', $msg);
	}

	function unlock()
	{
		unlink('./lock');
	}

	$action = $_GET['action'];
	
	header('Content-Type: application/json');
	if($action == 'lock') {
		$date = date('Y-m-d H:i:s');
		lock($date);
		echo (json_encode( '文件被锁住：'.$date));
	} else if($action == 'unlock'){
		unlock();
		echo (json_encode('文件被解锁：'));
	} else {
		if(file_exists('./lock')) {
			echo (json_encode('文件已被其他人与'. file_get_contents('./lock').'锁住，不能读取');
		} else {
			echo (json_encode(file_get_contents('./file.txt')));
		}
	}
?>
