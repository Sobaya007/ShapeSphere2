#vertex Proj

require Light;

require Position in View as vec3 pos;
require Normal in View as vec3 n;

// yawaraka orange

void main() {
    vec3 nrm = -normalize(n);
    vec3 camV = normalize(pos);
    vec3 col = vec3(1,0.5,0.1);
    vec3 acc = vec3(0);

    vec3 ligC = vec3(3,3,5),ligV;
    float fac,cus;
    for(int i=0;i<pointLightNum;i++){
        ligV = normalize(pointLights[i].pos-pos);
        fac = pow(length(pointLights[i].pos-pos),0.9);
        cus = 0;
        cus += max(0.,dot(-camV,nrm))/4.;
        cus *= max(0.2,1.-pow(1.-abs(dot(-camV,nrm)),3.));
        cus += max(0.,dot(ligV,nrm)*0.5+0.5)/6.;
        cus += max(0.,dot(ligV,nrm))/6.;

        acc += cus*ligC*col*4.0/fac * 2.0;
    }
    fragColor.rgb = acc;
    fragColor.a = length(pos) * length(pos) * 0.1;
}
