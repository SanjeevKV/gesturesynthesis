function [freq,m]=compute_energy(signal,percent,Fs)
%fft_x=abs(fftshift(fft(signal)));
m=mean(signal);    
signal=signal-mean(signal);
    
    fft_x=abs(fftshift(fft(signal,2^(nextpow2(length(signal))))));
    n=length(fft_x);
    fft_x=fft_x(n/2+1:n);
    t_n=length(fft_x);
    A=fft_x.*fft_x;
    total_energy=sum(A);
    cumilative=cumsum(A);
    threshold=percent*total_energy;
    iter=find(cumilative>=threshold);

   freq=(iter(1)/t_n)*Fs*0.5;

end