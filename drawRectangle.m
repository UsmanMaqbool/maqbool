function imageReturn = drawRectangle(image, Xmin, Ymin, width, height)
    imageReturn = image;
    intensity = 255;
    X1 = Xmin+1;
    Y1 = Ymin+1;
    X2 = Xmin + width-1;
    Y2 = Ymin + height-1;

    Xcenter = round((X1+X2)/2);
    Ycenter = round((Y1+Y2)/2);
    
    %bb(1) bb(2) bb(3)+bb(1) bb(4)+bb(2)
    
    for i=X1:X2
        imageReturn(i,Y1,1)=intensity;
        imageReturn(i,Y1+1,1)=intensity;
        imageReturn(i,Y1+2,1)=intensity;
    end
    for i=X1:X2
        imageReturn(i,Y2,1)=intensity;
        imageReturn(i,Y2-1,1)=intensity;
        imageReturn(i,Y2-2,1)=intensity;
    end
    for i=Y1:Y2
        imageReturn(X1,i,1)=intensity;
        imageReturn(X1+1,i,1)=intensity;
        imageReturn(X1+2,i,1)=intensity;
    end
    for i=Y1:Y2
        imageReturn(X2,i,1)=intensity;
        imageReturn(X2-1,i,1)=intensity;
        imageReturn(X2-2,i,1)=intensity;
    end
    
    %Comment the following for cycles if you don't want the cross in the centroid
    for i=Xcenter-3:Xcenter+3
        imageReturn(i,Ycenter,1)=intensity;
    end
    for i=Ycenter-3:Ycenter+3
        imageReturn(Xcenter,i,1)=intensity;
    end
end