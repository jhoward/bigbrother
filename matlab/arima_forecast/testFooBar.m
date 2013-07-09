function testFooBar( foo, bar, varargin )

if nargin < 2
   error(message('testFooBar - Not enough inputs'))
end

parser = inputParser;
parser.CaseSensitive = true;
parser.addOptional('foobar', false);
%parser.addRequired('foo');
%parser.addRequired('bar');

try 
  parser.parse(varargin{:});
catch exception
  exception.throwAsCaller();
end

foobar = parser.Results.foobar;
foo2 = parser.Results.foo;
bar2 = parser.Results.bar;

fprintf(1, 'Foo %i\n', foo);
fprintf(1, 'Foo2 %i\n', foo2);
fprintf(1, 'Bar %i\n', bar);
fprintf(1, 'Bar2 %i\n', bar2);
fprintf(1, 'FooBar %i\n', foobar);

end

