ps -ef | grep bot | grep -v grep | awk ' {print $ 2} '  | xargs matam -9
