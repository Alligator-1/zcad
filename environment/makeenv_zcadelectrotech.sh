mkdir ../cad
mkdir ../cad_source/autogenerated
rm -rf ../cad_source/autogenerated/*
rm -rf ../cad/*
rm -rf ../lib/*
cp -r runtimefiles/common/* ../cad
cp -r runtimefiles/zcadelectrotech/* ../cad
cp -r runtimefiles/restricted/* ../cad
typeexporter/typeexporter pathprefix=../cad_source/ outputfile=../cad/rtl/system.pas processfiles=typeexporter/zcad.files+typeexporter/zcadelectrotech.files
echo {\$DEFINE ELECTROTECH}>../cad_source/autogenerated/buildmode.inc
