
hash = Hashtable();
hash.Put('a',1);
hash.Put('random numbers',rand(1,5));
hash.Put('b','abcdefg...');
hash.Put('c',{'foo' 'goo' 'moo'});

s.title = 'Random Numbers and Mean';
s.data = rand(100);
s.m = mean(s.data);

hash.Put('my data struct',s);
hash

hash.IsKey('random numbers')
hash.Get('random numbers')
hash.Remove('random numbers');
hash.IsKey('random numbers')

k = hash.Keys();
v = hash.Values();
newhash = Hashtable(k,v);
newhash

newhash.IsEmpty
hash.Clear();
hash.IsEmpty