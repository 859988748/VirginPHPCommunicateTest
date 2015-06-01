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

	if($action == 'lock') {
		$date = date('Y-m-d H:i:s');
		lock($date);
		echo '文件被锁住：'.$date;
	} else if($action == 'unlock'){
		unlock();
		echo '文件被解锁：';
	} else {
		if(file_exists('./lock')) {
			echo '<html>';
			echo '<head>';
			echo '<title>时间</title>';
			echo '</head>';
			echo '<body>';
			echo '<h1 style="color:red;">'.'文件已被其他人与'. file_get_contents('./lock').'锁住，不能读取'.'</h1>';
			echo '</body>';
			echo '</html>';
		} else {
			echo '<html>';
			echo '<head>';
			echo '<title>时间</title>';
			echo '</head>';
			echo '<body>';
			echo '<h1 style="color:green;">'.file_get_contents('./file.txt').'</h1>';
			echo '</body>';
			echo '</html>';
		}
	}
?>