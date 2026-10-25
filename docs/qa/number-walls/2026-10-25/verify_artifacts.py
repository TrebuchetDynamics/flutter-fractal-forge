import hashlib, json, sys
from pathlib import Path
from PIL import Image
native, browser, output = map(Path, sys.argv[1:])
names = ['signedPagoda','rook','thueMorse','rudinShapiro','fibonacci','squares','replay-97','styled-97']
summary = {'native':{},'browser':{},'pngs':{},'crossRuntimeCells':0,'rgbToleranceLsb':1}
for name in names:
    record = json.loads((native/f'{name}.json').read_text())
    matrix = record['matrix']; rows=len(matrix); cols=len(matrix[0]); p=int(record['prime'])
    summary['crossRuntimeCells'] += rows*cols
    assert len(record['colors'])==p
    color_values={v:((c>>16)&255,(c>>8)&255,c&255,255) for v,c in record['colors'].items()}
    assert all(len(row)==cols and all(0<=int(v)<p for v in row) for row in matrix)
    for label, folder in [('native',native),('browser',browser)]:
        file=folder/f'{name}.png'
        image=Image.open(file).convert('RGBA'); assert image.size==(1280,720), (file,image.size)
        for row in range(rows):
            for col in range(cols):
                value=int(record['colors'][matrix[row][col]])
                expected=((value>>16)&255,(value>>8)&255,value&255,255)
                actual=image.getpixel((int((col+.5)*1280/cols),int((row+.5)*720/rows)))
                assert actual[3]==255 and all(abs(actual[i]-expected[i])<=1 for i in range(3)),(label,name,row,col,actual,expected)
                candidates=[v for v,c in color_values.items() if all(abs(actual[i]-c[i])<=1 for i in range(3))]
                assert candidates==[matrix[row][col]],(label,name,row,col,candidates,matrix[row][col])
        summary[label][name]={'dimensions':[1280,720],'matchedCells':rows*cols}
    decoded=json.loads((browser/f'{name}-matrix.json').read_text())
    assert decoded['matrix']==matrix
    if name=='signedPagoda':
        zero=sum(v=='0' for row in matrix for v in row)
        assert 0<zero<rows*cols
        dp=[[0]*(cols+1) for _ in range(rows+1)]; largest=0; framed=[]
        for r in range(rows):
            for c in range(cols):
                if matrix[r][c]=='0':
                    dp[r+1][c+1]=1+min(dp[r][c+1],dp[r+1][c],dp[r][c]); largest=max(largest,dp[r+1][c+1])
                    for size in range(1,dp[r+1][c+1]+1):
                        top,left=r-size+1,c-size+1
                        if top>0 and left>0 and r+1<rows and c+1<cols:
                            frame=[matrix[top-1][x] for x in range(left,c+1)]+[matrix[r+1][x] for x in range(left,c+1)]+[matrix[y][left-1] for y in range(top,r+1)]+[matrix[y][c+1] for y in range(top,r+1)]
                            if all(v!='0' for v in frame): framed.append({'row':top,'column':left+64,'size':size})
        summary['defaultWindows']={'zeroCells':zero,'nonzeroCells':rows*cols-zero,'largestVisibleZeroSquare':largest,'framedWindows':framed}
        assert framed
for folder in [native,browser]:
    for file in sorted(folder.glob('*.png')):
        with Image.open(file) as im:
            im.load(); dimensions=list(im.size)
        summary['pngs'][folder.name+'/'+file.name]={'dimensions':dimensions,'sha256':hashlib.sha256(file.read_bytes()).hexdigest()}
summary['harnessSha256']={p:hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in ['integration_test/flows/number_wall_journey_test.dart','test/playwright/number-wall-journey.spec.mjs']}
output.write_text(json.dumps(summary,indent=2)+'\n')
print('PASS:',len(names)*2,'decoded native/browser artworks;',summary['crossRuntimeCells'],'cross-runtime exact cells;',len(summary['pngs']),'PNGs decoded;',len(summary['defaultWindows']['framedWindows']),'default framed zero windows')
