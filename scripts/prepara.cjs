// Gera os arquivos pesados (OCR, leitor de código, ícones) a partir do node_modules
const fs=require('fs'),path=require('path');
const cp=(a,b)=>{fs.mkdirSync(path.dirname(b),{recursive:true});fs.copyFileSync(a,b);console.log('copiado',b);};
const nm='node_modules/';
cp(nm+'tesseract.js/dist/tesseract.min.js','www/ocr/tesseract.min.js');
cp(nm+'tesseract.js/dist/worker.min.js','www/ocr/worker.min.js');
cp(nm+'tesseract.js-core/tesseract-core-lstm.wasm.js','www/ocr/core/tesseract-core-lstm.wasm.js');
cp(nm+'tesseract.js-core/tesseract-core-simd-lstm.wasm.js','www/ocr/core/tesseract-core-simd-lstm.wasm.js');
// o Android não empacota bem arquivos .gz nos assets: grava descompactado
fs.mkdirSync('www/ocr/lang',{recursive:true});fs.writeFileSync('www/ocr/lang/por.traineddata',require('zlib').gunzipSync(fs.readFileSync(nm+'@tesseract.js-data/por/4.0.0_best_int/por.traineddata.gz')));console.log('gerado www/ocr/lang/por.traineddata');
cp(nm+'@zxing/browser/umd/zxing-browser.min.js','www/vendor/zxing-browser.min.js');
const sharp=require('sharp');
const D="M50 13 C50 13 24 43 24 61 A26 26 0 0 0 76 61 C76 43 50 13 50 13Z";
const fg=(sc)=>`<g transform="translate(${50-50*sc},${50-50*sc}) scale(${sc})"><path d="M71.4 68 A28 28 0 1 1 71.4 32" fill="none" stroke="#fff" stroke-width="9" stroke-linecap="round"/><path transform="translate(31,30.06) scale(.38)" d="${D}" fill="#fb7185"/></g>`;
const grad='<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#2563eb"/><stop offset="1" stop-color="#06b6d4"/></linearGradient></defs>';
const files={
 'icon-only.png':[1024,`${grad}<rect width="100" height="100" fill="url(#g)"/>${fg(1)}`],
 'icon-foreground.png':[1024,`${fg(0.62)}`],
 'icon-background.png':[1024,`${grad}<rect width="100" height="100" fill="url(#g)"/>`],
 'splash.png':[2732,`${grad}<rect width="100" height="100" fill="url(#g)"/>${fg(0.22)}`],
 'splash-dark.png':[2732,`<rect width="100" height="100" fill="#0f1115"/>${fg(0.22)}`]};
(async()=>{fs.mkdirSync('assets',{recursive:true});
for(const [n,[s,body]] of Object.entries(files)){
 const svg=`<svg xmlns="http://www.w3.org/2000/svg" width="${s}" height="${s}" viewBox="0 0 100 100">${body}</svg>`;
 await sharp(Buffer.from(svg)).png().toFile('assets/'+n);console.log('gerado assets/'+n);}
})();
