fdef int sum(int i, int) j {
     return i + j;
} ;

main {

fdef float sum(float i, float j) { # Not an error in S++
     return i + j;
} ;

  int s1 := sum(-10,20);
  float s2 := sum(10.0,-20.0);
  int s3 := 3 ^ -2 ^ 5;
  int s4 := s3 ^ (2 + 4 * 5) ^ - (13 / 5) ^ -2;
  bool b;

  if (s1 < s2 || s1 == s2) then
     b := s1 + s2 / (s1 + s2) >= 30;
  else 
     /# empty else #/
  fi
} ;
