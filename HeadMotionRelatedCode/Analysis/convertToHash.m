%% Based on Java HashCode method.
% A is a vector of numbers between 2 to 9
function hash=convertToHash(A)
    
    n=length(A);pos=n-1;
    hash=0;
    A=A-2;
    for i=1:length(A)
        hash=hash+A(i)*8^pos;
        pos=pos-1;
    end
end