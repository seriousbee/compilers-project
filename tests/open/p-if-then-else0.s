fdef foo( int pos ) { 
	if (pos == -1) then
		return 0;
	else 
		return 1;
	fi	
	return foo(pos-1) + foo(pos-2);
} ;

fdef int add (int x, int y) {
	return x + y;
} ;

main {
	foo( 13 );
	return;
};
