#!/usr/bin/env python3
"""
THE LEGEND OF MEILE — Video Renderer
Renders a 960x540 30fps MP4 tribute video directly.
Uses Pillow for drawing + ffmpeg for encoding.
"""
import math, os, subprocess, struct, wave, shutil
from PIL import Image, ImageDraw, ImageFont

W, H, FPS = 960, 540, 30
TOTAL_SEC = 100
FRAME_DIR = "/tmp/meile_frames"
OUTPUT = "/home/user/Dr-Meile-22th/meile_tribute.mp4"

# ═══════ COLORS ═══════
C = {
    "skin_lt":(253,228,200),"skin":(242,197,160),"skin_md":(217,168,124),
    "skin_dk":(191,138,94),"skin_sh":(140,98,57),
    "hair_lt":(200,200,210),"hair":(168,168,180),"hair_md":(142,142,154),
    "hair_dk":(106,106,118),"hair_sh":(74,74,86),
    "shirt_lt":(216,232,244),"shirt":(176,200,224),"shirt_md":(144,174,208),"shirt_dk":(104,136,176),
    "uga_red":(186,12,47),"uga_red_dk":(138,8,32),
    "gold":(255,208,64),"gold_dk":(200,160,32),"gold_lt":(255,232,128),
    "swiss":(255,0,0),
    "sky_top":(72,136,208),"sky_mid":(96,168,232),"sky_bot":(160,212,248),
    "grass1":(72,168,72),"grass2":(56,144,56),"grass3":(40,120,40),"grass4":(104,192,104),
    "water1":(32,96,160),"water2":(24,72,128),
    "mt1":(96,112,128),"mt2":(80,96,112),"mt_snow":(232,240,248),
    "wood":(139,105,20),"wood_dk":(107,78,16),"wood_lt":(171,137,52),
    "stone":(144,144,152),"stone_dk":(104,104,112),"stone_lt":(176,176,184),
    "coffee":(111,78,55),"coffee_lt":(159,126,87),
    "white":(248,248,248),"black":(16,16,24),
    "space1":(4,4,14),"space2":(10,10,40),
    "land":(74,122,74),"land_lt":(90,138,90),
}

try:
    FONT_SM = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", 10)
    FONT_MD = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", 14)
    FONT_LG = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", 22)
    FONT_XL = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", 36)
    FONT_TITLE = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", 48)
except:
    FONT_SM=FONT_MD=FONT_LG=FONT_XL=FONT_TITLE=ImageFont.load_default()

# ═══════ HELPERS ═══════
def grad_v(d,x,y,w,h,c1,c2):
    for r in range(max(1,int(h))):
        t=r/max(h-1,1)
        d.rectangle([x,y+r,x+w-1,y+r],fill=tuple(int(c1[i]+(c2[i]-c1[i])*t)for i in range(3)))

def grad_h(d,x,y,w,h,c1,c2):
    for cl in range(max(1,int(w))):
        t=cl/max(w-1,1)
        d.rectangle([x+cl,y,x+cl,y+h-1],fill=tuple(int(c1[i]+(c2[i]-c1[i])*t)for i in range(3)))

def txt_c(d,text,y,font,color):
    bb=d.textbbox((0,0),text,font=font); tw=bb[2]-bb[0]
    d.text(((W-tw)//2,y),text,fill=color,font=font)

def txt_cs(d,text,y,font,color,sh=(0,0,0)):
    bb=d.textbbox((0,0),text,font=font); tw=bb[2]-bb[0]; x=(W-tw)//2
    d.text((x+2,y+2),text,fill=sh,font=font); d.text((x,y),text,fill=color,font=font)

def swiss_flag(d,x,y,sz):
    d.rectangle([x,y,x+sz,y+sz],fill=C["swiss"])
    sw=sz//4
    d.rectangle([x+sz//2-sw//2,y+sz//8,x+sz//2+sw//2,y+sz-sz//8],fill=C["white"])
    d.rectangle([x+sz//8,y+sz//2-sw//2,x+sz-sz//8,y+sz//2+sw//2],fill=C["white"])

def dialog(d,x,y,w,h,title,body):
    d.rectangle([x,y,x+w,y+h],fill=(0,0,20))
    d.rectangle([x+2,y+2,x+w-2,y+h-2],outline=C["gold"],width=2)
    for cx,cy in [(x+4,y+4),(x+w-10,y+4),(x+4,y+h-10),(x+w-10,y+h-10)]:
        d.rectangle([cx,cy,cx+6,cy+6],fill=C["gold_lt"])
    bb=d.textbbox((0,0),title,font=FONT_SM); tw=bb[2]-bb[0]
    d.text((x+(w-tw)//2,y+12),title,fill=C["white"],font=FONT_SM)
    bb=d.textbbox((0,0),body,font=FONT_SM); tw=bb[2]-bb[0]
    d.text((x+(w-tw)//2,y+30),body,fill=C["gold_lt"],font=FONT_SM)

def bubble(d,x,y,lines):
    mw=max(len(l) for l in lines)*7+24; h=len(lines)*16+16
    d.rounded_rectangle([x,y,x+mw,y+h],radius=8,fill=C["white"],outline=(64,64,72),width=2)
    d.polygon([(x+20,y+h),(x+15,y+h+12),(x+30,y+h)],fill=C["white"])
    for i,l in enumerate(lines):
        d.text((x+12,y+10+i*16),l,fill=(32,32,40),font=FONT_SM)

def stars(d,f,n=120):
    for i in range(n):
        sx=(i*173.7+f*(1+i%3)*0.15)%W; sy=(i*97.3+f*(i%2)*0.05)%H
        br=0.4+math.sin(f*0.04+i*0.7)*0.4
        if br>0.2:
            v=int(min(255,br*255))
            d.rectangle([int(sx),int(sy),int(sx)+1,int(sy)+1],fill=(v,v,int(v*0.9)))

def body(d,ox,oy,sc,f):
    s=sc
    # Hair
    for i in range(-2,12):
        for j in range(-2,5):
            if (i-5)**2/30+(j-2)**2/8<1:
                cols=[C["hair"],C["hair_lt"],C["hair_md"],C["hair_dk"]]
                x,y_=int(ox+(i+5)*s),int(oy+j*s)
                d.rectangle([x,y_,x+int(s),y_+int(s)],fill=cols[abs((i+j*3)%4)])
    # Face
    for i in range(8):
        for j in range(8):
            if (i-4)**2/18+(j-3)**2/18<1:
                c=C["skin"] if i>2 else C["skin_md"]
                x,y_=int(ox+(i+4)*s),int(oy+(j+5)*s)
                d.rectangle([x,y_,x+int(s),y_+int(s)],fill=c)
    # Eyes
    for ex in [6,10]:
        d.rectangle([int(ox+ex*s),int(oy+8*s),int(ox+(ex+1)*s),int(oy+9*s)],fill=C["black"])
    # Smile
    for i in range(3):
        d.rectangle([int(ox+(6+i)*s),int(oy+11*s),int(ox+(7+i)*s),int(oy+12*s)],fill=(192,128,112))
    # Shirt
    for i in range(12):
        for j in range(10):
            if abs(i-6)<6+j*0.15:
                c=C["shirt_lt"] if i%3==0 else C["shirt"]
                d.rectangle([int(ox+(i+3)*s),int(oy+(j+14)*s),int(ox+(i+4)*s),int(oy+(j+15)*s)],fill=c)
    # Arms
    sw=math.sin(f*0.15)*2*s
    d.rectangle([int(ox+2*s),int(oy+(16+sw)*s),int(ox+3*s),int(oy+(22+sw)*s)],fill=C["shirt_md"])
    d.rectangle([int(ox+15*s),int(oy+(16-sw)*s),int(ox+16*s),int(oy+(22-sw)*s)],fill=C["shirt_md"])
    # Pants + shoes
    d.rectangle([int(ox+5*s),int(oy+24*s),int(ox+8*s),int(oy+32*s)],fill=(74,74,88))
    d.rectangle([int(ox+10*s),int(oy+24*s),int(ox+13*s),int(oy+32*s)],fill=(74,74,88))
    lp=math.sin(f*0.15)*s
    d.rectangle([int(ox+4*s),int(oy+(32+lp)*s),int(ox+9*s),int(oy+(34+lp)*s)],fill=(58,42,26))
    d.rectangle([int(ox+10*s),int(oy+(32-lp)*s),int(ox+15*s),int(oy+(34-lp)*s)],fill=(58,42,26))

def portrait(d,ox,oy,sc):
    s=sc
    # Hair
    for i in range(-2,22):
        for j in range(-3,10):
            if (i-10)**2/120+(j-3)**2/50<1:
                cols=[C["hair"],C["hair_lt"],C["hair_md"],C["hair_dk"]]
                d.rectangle([int(ox+i*s),int(oy+j*s),int(ox+(i+1)*s),int(oy+(j+1)*s)],fill=cols[abs(int(i+j*3+math.sin(i*0.4)*1.5))%4])
    # Face
    for i in range(16):
        for j in range(18):
            if (i-8)**2/70+(j-8)**2/90<1:
                c=C["skin"]
                if i<5: c=C["skin_md"]
                if j>11: c=C["skin_md"]
                if j<3 and abs(i-8)<5: c=C["skin_lt"]
                d.rectangle([int(ox+(i+2)*s),int(oy+(j+8)*s),int(ox+(i+3)*s),int(oy+(j+9)*s)],fill=c)
    # Eyes
    for ex in [5,12]:
        for i in range(3):
            for j in range(2):
                d.rectangle([int(ox+(ex+i)*s),int(oy+(14+j)*s),int(ox+(ex+i+1)*s),int(oy+(15+j)*s)],fill=C["white"])
        d.rectangle([int(ox+(ex+1)*s),int(oy+14*s),int(ox+(ex+2)*s),int(oy+16*s)],fill=(92,72,48))
        d.rectangle([int(ox+(ex+1)*s),int(oy+15*s),int(ox+(ex+2)*s),int(oy+16*s)],fill=C["black"])
    # Brows
    for i in range(4):
        d.rectangle([int(ox+(4+i)*s),int(oy+12*s),int(ox+(5+i)*s),int(oy+13*s)],fill=C["hair_dk"])
        d.rectangle([int(ox+(12+i)*s),int(oy+12*s),int(ox+(13+i)*s),int(oy+13*s)],fill=C["hair_dk"])
    # Nose
    d.rectangle([int(ox+9*s),int(oy+17*s),int(ox+11*s),int(oy+19*s)],fill=C["skin_dk"])
    # Smile
    for i in range(6):
        cv=1 if 1<=i<=4 else 0
        d.rectangle([int(ox+(7+i)*s),int(oy+(21+cv)*s),int(ox+(8+i)*s),int(oy+(22+cv)*s)],fill=(192,128,112))
    for i in range(4):
        d.rectangle([int(ox+(8+i)*s),int(oy+22*s),int(ox+(9+i)*s),int(oy+23*s)],fill=C["white"])
    # Neck + shirt
    for i in range(4):
        d.rectangle([int(ox+(8+i)*s),int(oy+26*s),int(ox+(9+i)*s),int(oy+29*s)],fill=C["skin"])
    for i in range(20):
        for j in range(12):
            if abs(i-10)<10+j*0.3:
                c=C["shirt_lt"] if i%3==0 else (C["shirt_dk"] if i<5 else C["shirt"])
                d.rectangle([int(ox+i*s),int(oy+(j+29)*s),int(ox+(i+1)*s),int(oy+(j+30)*s)],fill=c)

def mountains(d,yb):
    pts=[(0,yb)]
    for x,dy in [(80,-120),(200,-80),(340,-160),(480,-90),(600,-140),(750,-100),(900,-130),(960,-60)]:
        pts.append((x,yb+dy))
    pts.append((W,yb))
    d.polygon(pts,fill=C["mt2"])
    pts2=[(0,yb+20)]
    for x,dy in [(100,-60),(250,-30),(400,-80),(550,-40),(700,-70),(850,-30),(960,0)]:
        pts2.append((x,yb+dy))
    pts2.append((W,yb+20))
    d.polygon(pts2,fill=C["mt1"])
    for px_,py_,r in [(340,yb-160,30),(600,yb-140,25),(900,yb-130,20),(80,yb-120,18)]:
        d.polygon([(px_-r,py_+int(r*0.6)),(px_,py_),(px_+r,py_+int(r*0.6))],fill=C["mt_snow"])

def uga_arch(d,x,y,s):
    d.rectangle([x,y+30*s,x+20*s,y+110*s],fill=C["stone"])
    d.rectangle([x+80*s,y+30*s,x+100*s,y+110*s],fill=C["stone"])
    d.rectangle([x+30*s,y+30*s,x+42*s,y+110*s],fill=C["stone_dk"])
    d.rectangle([x-5*s,y+15*s,x+105*s,y+33*s],fill=C["stone_lt"])
    d.rectangle([x-2*s,y+8*s,x+102*s,y+18*s],fill=C["stone"])
    for i in range(7):
        d.rectangle([x+(15+i*10)*s,y+33*s,x+(17+i*10)*s,y+110*s],fill=(40,40,40))
    d.rectangle([x+12*s,y+60*s,x+90*s,y+62*s],fill=(40,40,40))

def coffee_cup(d,x,y,s,f):
    d.ellipse([x-2*s,y+14*s,x+18*s,y+22*s],fill=(224,216,208))
    d.rounded_rectangle([x,y,x+16*s,y+16*s],radius=3,fill=(248,240,232))
    d.rounded_rectangle([x+2*s,y+3*s,x+14*s,y+13*s],radius=2,fill=C["coffee"])
    d.rectangle([x+4*s,y+5*s,x+10*s,y+7*s],fill=C["coffee_lt"])
    for i in range(3):
        sy_=y-6*s+int(math.sin(f*0.08+i*2)*3*s)
        d.rectangle([int(x+(4+i*4)*s),int(sy_),int(x+(6+i*4)*s),int(sy_+4*s)],fill=(255,255,255,160))

def microbe(d,x,y,f,sc):
    wb=int(math.sin(f*0.06)*3*sc)
    cx,cy=int(x+wb),int(y)
    r=int(10*sc)
    d.ellipse([cx-r,cy-r,cx+r,cy+r],fill=(64,168,72))
    d.ellipse([cx-int(7*sc),cy-int(7*sc),cx+int(7*sc),cy+int(7*sc)],fill=(96,200,104))
    for i in range(3):
        a=i*2.1+f*0.04
        d.line([(cx,cy),(cx+int(math.cos(a)*14*sc),cy+int(math.sin(a)*14*sc))],fill=(64,168,72),width=max(1,int(2*sc)))
    for dx in [-3,3]:
        ex,ey=int(cx+dx*sc),int(cy-2*sc)
        d.ellipse([ex-int(2*sc),ey-int(2*sc),ex+int(2*sc),ey+int(2*sc)],fill=C["white"])
        d.ellipse([ex-int(sc),ey-int(sc),ex+int(sc),ey+int(sc)],fill=C["black"])

def bezier(ax,ay,bx,by,cx,cy,t):
    x=(1-t)**2*ax+2*(1-t)*t*bx+t**2*cx
    y=(1-t)**2*ay+2*(1-t)*t*by+t**2*cy
    return(int(x),int(y))

# ═══════ SCENES ═══════
def scene_title(d,t,f):
    grad_v(d,0,0,W,H,C["space1"],C["space2"]); stars(d,f)
    for i in range(5):
        sx=(i*251+f*0.5)%W; sy=(i*167)%(H//2)
        b=math.sin(f*0.06+i*1.2)
        if b>0.5:
            v=int((b-0.3)*400)
            d.line([(int(sx),int(sy)),(int(sx+15),int(sy-5))],fill=(v,v,v),width=1)
    if t>0.5: txt_cs(d,"THE LEGEND OF",120,FONT_LG,C["gold"],(40,30,0))
    if t>1.2: txt_cs(d,"MEILE",165,FONT_TITLE,C["uga_red"],(64,5,15))
    if t>2:
        txt_c(d,"22 YEARS AT THE UNIVERSITY OF GEORGIA",225,FONT_SM,C["gold_lt"])
        txt_c(d,"2003  —  2025",245,FONT_SM,(136,136,160))
    if t>3:
        swiss_flag(d,W//2-80,275,28)
        d.ellipse([W//2+50,278,W//2+80,308],fill=C["uga_red"])
        d.ellipse([W//2+54,282,W//2+76,304],fill=C["black"])
    if t>3.5: txt_c(d,"A  16-BIT  TRIBUTE",340,FONT_SM,(96,96,128))
    d.rectangle([0,H-40,W,H],fill=C["uga_red"])
    d.rectangle([0,H-42,W,H-40],fill=C["gold"])
    txt_c(d,"FROM THE MEILE LAB WITH LOVE",H-30,FONT_SM,C["white"])
    if t>1 and(f//20)%2==0: txt_c(d,">>> CLICK TO START <<<",400,FONT_MD,(170,170,170))

def scene_swiss(d,t,f):
    grad_v(d,0,0,W,int(H*0.6),C["sky_top"],C["sky_bot"])
    for i in range(5):
        cx=int((i*220+t*20)%1200-120); cy=int(40+i*30+math.sin(i*2)*20)
        d.ellipse([cx-25,cy-15,cx+25,cy+15],fill=(255,255,255,128))
    mountains(d,240)
    grad_v(d,0,340,W,H-340,C["grass1"],C["grass3"])
    for x in range(0,W,6):
        h=int(4+math.sin(x*0.3)*2)
        d.rectangle([x,340-h,x+3,342],fill=C["grass4"])
    fc=[(248,224,64),(240,96,160),(240,240,248),(160,96,240)]
    for i in range(15):
        d.rectangle([(i*97)%W,360+(i*53)%80,(i*97)%W+3,363+(i*53)%80],fill=fc[i%4])
    # Chalet
    d.rectangle([620,260,740,340],fill=C["wood"])
    d.polygon([(610,260),(680,220),(750,260)],fill=C["wood_dk"])
    d.rectangle([640,280,660,300],fill=C["sky_bot"]); d.rectangle([700,280,720,300],fill=C["sky_bot"])
    d.rectangle([665,300,685,340],fill=C["wood_dk"])
    d.rectangle([580,240,583,340],fill=C["wood_dk"]); swiss_flag(d,583,240,30)
    if t>3:
        d.rectangle([50,270,230,340],fill=(216,208,192)); d.rectangle([50,262,230,272],fill=(192,184,168))
        for i in range(6): d.rectangle([60+i*28,275,68+i*28,335],fill=(184,176,160))
        d.ellipse([115,240,165,270],fill=(192,184,168))
        txt_cs(d,"ETH ZURICH",350,FONT_SM,(96,96,80),(0,0,0))
    wx=int(100+t*50) if t<4 else int(300+min(t-4,5)*40)
    body(d,wx,260,3,f)
    if t<4: dialog(d,W//2-200,15,400,55,"ZURICH, SWITZERLAND","Our hero begins his quest...")
    elif t<7: dialog(d,W//2-200,15,400,55,"1996: ETH ZURICH","Dipl. Nat.wiss. EARNED!")
    else: dialog(d,W//2-200,15,400,55,"THE QUEST FOR KNOWLEDGE","Next destination: AMERICA! >>>")

def scene_worldmap(d,t,f):
    grad_v(d,0,0,W,H,C["water2"],C["water1"])
    # Continents
    d.polygon([(500,125),(520,120),(555,118),(575,130),(570,150),(545,165),(520,165),(505,155),(495,140)],fill=C["land_lt"])
    d.polygon([(530,155),(545,150),(545,180),(535,185),(525,175)],fill=C["land"])
    d.polygon([(490,190),(540,185),(580,200),(590,240),(575,300),(550,340),(520,350),(500,310),(485,250),(478,210)],fill=C["land"])
    d.polygon([(80,65),(160,55),(260,70),(300,100),(290,140),(270,175),(230,200),(180,210),(130,200),(90,170),(65,130),(60,95)],fill=C["land_lt"])
    d.polygon([(210,200),(230,195),(240,225),(225,235),(208,220)],fill=C["land"])
    d.polygon([(195,260),(235,250),(265,280),(260,340),(245,390),(220,410),(195,370),(185,310),(183,275)],fill=C["land"])
    d.polygon([(580,65),(660,60),(740,75),(800,100),(820,140),(790,170),(730,175),(670,165),(620,145),(585,110)],fill=C["land"])
    d.polygon([(760,310),(820,300),(855,320),(855,355),(835,375),(800,378),(770,360),(755,335)],fill=C["land"])
    locs=[(540,140,"ETH ZURICH 1996",C["swiss"],0.5),(215,170,"GEORGIA TECH 1999",(179,163,105),3.5),
          (525,130,"UTRECHT Ph.D. 2003",(255,102,0),7.0),(220,180,"UGA PROFESSOR 2003",C["uga_red"],10.0)]
    for a,b in [(0,1),(1,2),(2,3)]:
        if t>locs[b][4]-1:
            ax,ay,bx,by=locs[a][0],locs[a][1],locs[b][0],locs[b][1]
            mx,my=(ax+bx)//2,min(ay,by)-60
            prog=min(1,(t-(locs[b][4]-1)))
            for i in range(int(20*prog)):
                if i%2==0:
                    p1=bezier(ax,ay,mx,my,bx,by,i/20)
                    p2=bezier(ax,ay,mx,my,bx,by,min((i+1)/20,prog))
                    d.line([p1,p2],fill=C["gold"],width=3)
    for lx,ly,label,col,lt in locs:
        if t>lt:
            gw=int(4+math.sin(f*0.08)*2)
            d.ellipse([lx-gw-4,ly-gw-4,lx+gw+4,ly+gw+4],fill=(*col,80))
            d.ellipse([lx-gw,ly-gw,lx+gw,ly+gw],fill=col)
            d.ellipse([lx-3,ly-3,lx+3,ly+3],fill=C["white"])
            bb=d.textbbox((0,0),label,font=FONT_SM); tw=bb[2]-bb[0]
            d.text((lx-tw//2,ly-18),label,fill=C["white"],font=FONT_SM)
    banners=[(3.5,6.5,"M.Sc. UNLOCKED!","Georgia Institute of Technology"),
             (7,10,"Ph.D. UNLOCKED!","Utrecht University, Netherlands"),
             (10,13,"PROFESSOR MODE ACTIVATED!","University of Georgia")]
    for bs,be,bt_,bsub in banners:
        if bs<t<be:
            d.rectangle([W//2-200,H-70,W//2+200,H-20],fill=(60,45,0))
            d.rectangle([W//2-200,H-70,W//2+200,H-20],outline=C["gold"],width=2)
            txt_c(d,bt_,H-62,FONT_SM,C["white"]); txt_c(d,bsub,H-42,FONT_SM,C["gold"])
    xp=min(1,t/12)
    d.rectangle([20,15,320,31],fill=(10,10,40)); d.rectangle([20,15,320,31],outline=(64,64,96),width=1)
    d.rectangle([22,17,int(22+296*xp),27],fill=(64,176,64))
    d.text((25,17),f"KNOWLEDGE {int(xp*100)}%",fill=C["white"],font=FONT_SM)

def scene_lab(d,t,f):
    grad_v(d,0,0,W,H,(240,236,224),(224,216,200))
    for x in range(0,W,30):
        for y in range(int(H*0.7),H,30):
            d.rectangle([x,y,x+30,y+30],fill=(216,208,192) if((x//30)+(y//30))%2==0 else(232,224,208))
    d.rectangle([40,30,440,210],fill=C["white"]); d.rectangle([40,30,440,210],outline=(150,150,150),width=4)
    d.rectangle([40,210,440,218],fill=(192,192,192))
    d.rectangle([60,208,80,212],fill=(32,64,192)); d.rectangle([90,208,110,212],fill=(192,32,32)); d.rectangle([120,208,140,212],fill=(32,160,32))
    eqs=[("dC/dt = D*nabla^2 C - v*nabla C + R",(24,64,160),60),("f_i(x+e_i dt, t+dt) = f_i(x,t)",(24,64,160),85),
         ("  + Omega_i [f_i^eq - f_i]",(24,64,160),105),("CH4 + SO4(2-) -> HCO3- + HS-",(160,32,32),135),
         ("BIOFILM <-> PORE NETWORK",(32,128,32),160),("Pe = vL/D    Da = kL/v",(24,64,160),185)]
    for i,(eq,col,ey) in enumerate(eqs):
        if t>i*1.0: d.text((60,ey),eq,fill=col,font=FONT_SM)
    portrait(d,580,80,5)
    d.rectangle([500,340,900,352],fill=C["wood"]); d.rectangle([510,352,522,412],fill=C["wood_dk"]); d.rectangle([880,352,892,412],fill=C["wood_dk"])
    d.rounded_rectangle([600,310,696,376],radius=4,fill=(48,48,56))
    grad_v(d,606,316,84,54,(10,20,40),(16,32,64))
    cc=[(96,240,96),(64,160,240),(240,224,64),(240,128,64),(160,112,240)]
    for j in range(7): d.rectangle([612,318+j*7,612+(6+(j*7)%12)*3,318+j*7+3],fill=cc[j%5])
    d.rounded_rectangle([594,376,702,382],radius=2,fill=(72,72,80))
    coffee_cup(d,730,310,3,f)
    for i in range(4): d.rectangle([790+i*2,320-i*3,830+i*2,355-i*3],fill=(248,248,240))
    for i in range(5): microbe(d,80+i*100+int(math.sin(f*0.015+i*1.7)*30),340+int(math.cos(f*0.02+i*1.3)*20),f+i*40,1.5)
    d.rectangle([0,H-45,W,H],fill=(10,10,30)); d.rectangle([0,H-47,W,H-45],fill=C["gold"])
    topics=["Reactive Transport","Biogeochem Cycling","Microbial Metabolism","Salt Marsh Carbon","Iron Cycling","Hydrothermal Vents","Oil Spill Impacts","Pore-Scale Modeling"]
    sx=int(W-(f*1.5)%(len(topics)*200+W))
    for i,tp in enumerate(topics): d.text((sx+i*200,H-35),"* "+tp,fill=C["gold"],font=FONT_SM)
    d.rectangle([0,0,W,28],fill=C["uga_red"]); txt_c(d,"RESEARCH SKILLS — ALL MAXED OUT",8,FONT_SM,C["white"])

def scene_comedy1(d,t,f):
    grad_v(d,0,0,W,H,(237,228,212),(221,212,196))
    if t<5:
        d.rectangle([700,30,900,170],fill=C["sky_bot"]); d.rectangle([700,30,900,170],outline=C["wood_dk"],width=4)
        body(d,120,200,3,f)
        for i in range(12): coffee_cup(d,340+(i%4)*80,250+(i//4)*40,2.5,f+i*15)
        bubble(d,180,100,["CAN'T MODEL MICROBES","WITHOUT COFFEE...","IT'S THERMODYNAMICS!"])
        dialog(d,W//2-200,15,400,55,"COFFEE EVERY 2 HOURS","Status: CAFFEINATED | Refills: INF")
    else:
        d.rounded_rectangle([400,80,880,360],radius=8,fill=(200,208,216))
        d.rectangle([405,85,875,215],fill=(216,224,232)); d.rectangle([405,220,875,355],fill=(208,216,224))
        d.rectangle([400,80,880,360],outline=(160,168,176),width=3)
        for r in range(3):
            for c_ in range(6):
                bx,by=420+c_*70,95+r*55
                d.rounded_rectangle([bx,by,bx+50,by+40],radius=3,fill=(232,64,64))
                d.rectangle([bx+4,by+4,bx+46,by+16],fill=(248,240,224))
                d.rectangle([bx+8,by+8,bx+40,by+14],fill=C["uga_red"])
                d.rectangle([bx+4,by+30,bx+46,by+38],fill=(248,216,72))
        body(d,200,200,3,f)
        d.rectangle([280,340,340,348],fill=(160,160,160)); d.rectangle([290,310,340,340],fill=(176,176,176))
        d.ellipse([285,348,295,358],fill=(96,96,96)); d.ellipse([335,348,345,358],fill=(96,96,96))
        bubble(d,100,90,["AH YES, FROZEN PIZZA","MARGHERITA...","THE SWISS-APPROVED","DINNER OF CHAMPIONS!"])
        dialog(d,W//2-200,15,400,55,"TRADER JOE'S QUEST","Frozen Food: LEGENDARY")

def scene_comedy2(d,t,f):
    grad_v(d,0,0,W,H,(237,228,212),(221,212,196))
    if t<5:
        d.rounded_rectangle([80,40,880,260],radius=4,fill=(42,74,42))
        d.rectangle([80,40,880,260],outline=C["wood_dk"],width=5); d.rectangle([80,260,880,270],fill=C["wood_lt"])
        d.text((120,65),"FINAL EXAM:",fill=(200,216,192),font=FONT_MD)
        d.text((120,95),"Given: coffee = life",fill=(200,216,192),font=FONT_SM)
        d.text((120,115),"       frozen_food = energy",fill=(200,216,192),font=FONT_SM)
        d.text((120,140),"       teaching = passion",fill=(200,216,192),font=FONT_SM)
        d.text((120,170),"Solve: HAPPINESS = ???",fill=(200,216,192),font=FONT_SM)
        d.text((550,165),"INF !",fill=C["gold"],font=FONT_LG)
        body(d,440,280,3,f); d.line([(480,310),(560,180)],fill=C["wood_dk"],width=3)
        sc_=[(231,76,60),(52,152,219),(46,204,113),(243,156,18),(155,89,182),(26,188,156),(230,126,34),(232,67,147)]
        hc=[(44,24,16),(74,48,32),(26,26,26),(107,72,48),(60,42,28),(34,34,34),(85,51,51),(42,26,10)]
        for r in range(2):
            for c_ in range(4):
                sx,sy=100+c_*110,int(370+r*55+math.sin(f*0.08+c_+r*3)*3)
                d.rectangle([sx-5,sy+30,sx+65,sy+36],fill=C["wood_lt"])
                d.rectangle([sx+15,sy,sx+35,sy+28],fill=sc_[(r*4+c_)%8])
                d.ellipse([sx+15,sy-18,sx+35,sy+2],fill=C["skin"])
                d.rectangle([sx+13,sy-22,sx+37,sy-14],fill=hc[(r*4+c_)%8])
        dialog(d,W//2-200,5,400,32,"22 YEARS OF TEACHING","1,000+ Students Inspired!")
    else:
        d.rectangle([0,0,W//2,H],fill=(240,237,232)); d.rectangle([W//2,0,W,H],fill=(245,232,216))
        swiss_flag(d,60,50,60); txt_cs(d,"SWISS PRECISION",140,FONT_MD,(51,51,51))
        d.ellipse([W//4-45,175,W//4+45,265],fill=C["white"],outline=(51,51,51),width=3)
        for i in range(12):
            a=i*math.pi/6
            d.line([(int(W/4+math.cos(a)*38),int(220+math.sin(a)*38)),(int(W/4+math.cos(a)*42),int(220+math.sin(a)*42))],fill=(51,51,51),width=2)
        d.line([(W//4,220),(W//4,185)],fill=(51,51,51),width=3)
        sa=f*0.05
        d.line([(W//4,220),(int(W/4+math.cos(sa)*35),int(220+math.sin(sa)*35))],fill=C["swiss"],width=2)
        d.text((W//4-60,290),"ALWAYS ON TIME",fill=(85,85,85),font=FONT_SM)
        d.text((W//4-50,310),"METICULOUS",fill=(85,85,85),font=FONT_SM)
        txt_cs(d,"GEORGIA SOUL",50,FONT_MD,C["uga_red"])
        body(d,int(W*3/4-15),100,2.5,f); coffee_cup(d,int(W*3/4+40),180,2.5,f)
        txt_cs(d,"GO DAWGS!",300,FONT_MD,C["uga_red"])
        d.text((int(W*3/4)-50,330),"WARM VIBES",fill=(139,105,20),font=FONT_SM)
        d.text((int(W*3/4)-55,350),"BEST ADVISOR",fill=(139,105,20),font=FONT_SM)
        grad_v(d,W//2-3,0,6,H,C["gold"],C["gold_dk"])
        dialog(d,W//2-200,5,400,32,"BEST OF BOTH WORLDS","Swiss + Southern = LEGENDARY")

def scene_stats(d,t,f):
    grad_v(d,0,0,W,H,(8,8,30),(14,14,46))
    for x in range(0,W,24): d.line([(x,0),(x,H)],fill=(22,22,62),width=1)
    for y in range(0,H,24): d.line([(0,y),(W,y)],fill=(22,22,62),width=1)
    portrait(d,30,50,5)
    d.rectangle([310,25,930,515],fill=(15,15,45)); d.rectangle([310,25,930,515],outline=C["gold"],width=3)
    d.rectangle([316,31,924,509],outline=C["gold_dk"],width=1)
    grad_h(d,330,40,580,30,C["uga_red_dk"],C["uga_red"])
    bb=d.textbbox((0,0),"PROF. DR. CHRISTOF MEILE",font=FONT_MD); tw=bb[2]-bb[0]
    d.text((620-tw//2,44),"PROF. DR. CHRISTOF MEILE",fill=C["white"],font=FONT_MD)
    d.rectangle([330,80,910,82],fill=C["gold"])
    for i,line in enumerate(["CLASS: Legendary Professor","ORIGIN: Zurich, Switzerland","BASE: Athens, Georgia, USA","YEARS ACTIVE: 22 (2003-2025)"]):
        d.text((340,90+i*16),line,fill=C["gold_lt"] if i==0 else(136,136,160),font=FONT_SM)
    d.rectangle([330,158,910,160],fill=(48,48,96))
    stats=[("TEACHING",99,(64,192,64)),("RESEARCH",97,(64,128,224)),("COFFEE LV",100,C["coffee"]),
           ("KINDNESS",100,(224,96,192)),("MODELING",98,(64,176,176)),("FROZEN FOOD",95,(224,96,64)),("MENTORING",99,C["gold"])]
    for i,(name,val,col) in enumerate(stats):
        if t>i*0.5:
            sy=178+i*38; anim=min(val,t*20); fp=min(val,anim)/100
            d.text((340,sy),name,fill=(176,176,192),font=FONT_SM)
            d.rectangle([490,sy-2,740,sy+12],fill=(26,26,48)); d.rectangle([490,sy-2,740,sy+12],outline=(64,64,96),width=1)
            fw=int(248*fp)
            if fw>0: d.rectangle([491,sy-1,491+fw,sy+11],fill=col)
            d.text((750,sy),str(int(anim)),fill=C["white"],font=FONT_SM)
            if anim>=95: d.text((790,sy),"MAX!",fill=C["gold"],font=FONT_SM)
    if t>4: txt_c(d,"TOTAL XP: INF  |  RANK: LEGENDARY",480,FONT_SM,C["gold"])

def scene_campus(d,t,f):
    grad_v(d,0,0,W,int(H*0.5),C["sky_bot"],C["sky_mid"])
    for i in range(8):
        tx=i*130+20
        d.rectangle([tx+15,150,tx+23,200],fill=C["wood_dk"])
        d.ellipse([tx-6,115,tx+44,165],fill=C["grass3"]); d.ellipse([tx-1,110,tx+39,155],fill=C["grass1"])
    grad_v(d,0,200,W,H-200,C["grass1"],C["grass3"])
    for y in range(230,H,8):
        for x in range(350,610,16):
            d.rectangle([x,y,x+14,y+6],fill=(200,168,144) if((x//16)+(y//8))%2==0 else(184,152,128))
    uga_arch(d,400,130,2)
    body(d,455+int(math.sin(t*2)*5),210,3,f)
    sc_=[(231,76,60),(52,152,219),(46,204,113),(243,156,18),(155,89,182),(26,188,156),(230,126,34),(232,67,147)]
    for i in range(8):
        sx=int(60+i*60+math.sin(f*0.05+i)*5); sy=int(280+math.sin(f*0.08+i*2)*3)
        d.rectangle([sx+6,sy,sx+22,sy+22],fill=sc_[i%8]); d.ellipse([sx+6,sy-18,sx+22,sy-2],fill=C["skin"])
    if t>2:
        d.rectangle([80,30,W-80,80],fill=C["uga_red"]); d.rectangle([80,30,W-80,80],outline=C["gold"],width=2)
        txt_c(d,"22 YEARS OF EXCELLENCE AT UGA",38,FONT_MD,C["white"])
        txt_c(d,"MARINE SCIENCES DEPARTMENT",60,FONT_SM,C["gold"])
    if t>4:
        cc=[C["uga_red"],(64,176,64),(64,128,224),C["gold"],(224,96,192),(64,176,176)]
        for i in range(40):
            cx=int((i*47+f*3)%W); cy=int((f*2+i*31)%H)
            d.rectangle([cx,cy,cx+4,cy+4],fill=cc[i%6])

def scene_finale(d,t,f):
    grad_v(d,0,0,W,H,C["space1"],C["space2"]); stars(d,f,150)
    if t<5: portrait(d,W//2-60,80,6)
    if t>2:
        txt_cs(d,"THANK YOU",30,FONT_XL,C["gold"],(30,20,0))
        txt_cs(d,"DR. MEILE!",70,FONT_XL,C["uga_red"],(50,5,10))
    if t>4:
        credits=["22 YEARS OF INSPIRING","MARINE SCIENCE AT UGA","","FROM ZURICH TO ATHENS, GA","A JOURNEY OF DISCOVERY","",
                 "SKILLS MASTERED:","* Reactive Transport Modeling","* Biogeochemical Cycling","* Microbial Metabolism",
                 "* Being an Amazing Mentor","* Coffee Consumption (LEGENDARY)","* Frozen Food Connoisseurship",
                 "* Lattice Boltzmann Methods","","WITH GRATITUDE FROM","THE MEILE LAB FAMILY","",
                 "DANKE SCHON, PROFESSOR!","THANK YOU!","","GO DAWGS!","",
                 "Made with love by the Meile Lab","University of Georgia  2025"]
        cy=int(H-(t-4)*15)
        for i,line in enumerate(credits):
            ly=cy+i*20
            if 90<ly<H-10:
                col=C["gold"] if line.startswith("*") else(C["uga_red"] if "DANKE" in line or "THANK" in line else(220,220,220))
                txt_c(d,line,ly,FONT_SM,col)
    if t>3:
        swiss_flag(d,20,H-55,28)
        d.ellipse([W-49,H-54,W-21,H-26],fill=C["uga_red"]); d.ellipse([W-45,H-50,W-25,H-30],fill=C["black"])
    if t>6:
        cc=[C["uga_red"],C["gold"],C["white"],C["grass1"],(64,128,224),C["swiss"]]
        for i in range(60):
            cx=int((i*37+f*2)%W); cy=int((f*1.5+i*23)%H); sz=int(2+math.sin(f*0.1+i)*2)
            d.rectangle([cx,cy,cx+sz,cy+sz],fill=cc[i%6])

# ═══════ RENDER LOOP ═══════
SCENE_MAP=[(0,7,scene_title),(7,18,scene_swiss),(18,32,scene_worldmap),(32,44,scene_lab),
           (44,54,scene_comedy1),(54,64,scene_comedy2),(64,76,scene_stats),(76,88,scene_campus),(88,100,scene_finale)]

def render_frame(fi):
    t=fi/FPS
    img=Image.new("RGBA",(W,H),(0,0,0,255))
    d=ImageDraw.Draw(img,"RGBA")
    for start,end,func in SCENE_MAP:
        if start<=t<end:
            func(d,t-start,fi); break
    else:
        scene_finale(d,t-88,fi)
    # Transitions
    for start,_,_ in SCENE_MAP:
        if start>0 and abs(t-start)<0.4:
            alpha=int((1-abs(t-start)/0.4)*180)
            d.rectangle([0,0,W,H],fill=(0,0,0,alpha))
    # Scanlines
    for y in range(0,H,2): d.rectangle([0,y,W,y],fill=(0,0,0,12))
    # Progress
    d.rectangle([0,H-3,W,H],fill=(34,34,34)); d.rectangle([0,H-3,int(W*t/TOTAL_SEC),H],fill=C["uga_red"])
    return img.convert("RGB")

# ═══════ AUDIO ═══════
SR=44100
def gen_note(freq,dur,wave="square",vol=0.15,env="sustain"):
    n=int(SR*dur); out=[]
    for i in range(n):
        t=i/SR; tn=i/max(n-1,1)
        if freq<=0: val=0
        else:
            ph=(t*freq)%1.0
            if wave=="square": val=1.0 if ph<0.5 else-1.0
            elif wave=="triangle": val=4.0*abs(ph-0.5)-1.0
            elif wave=="noise": val=(math.sin(t*freq*6.28)*43758.5453)%1.0*2-1
            else: val=math.sin(ph*6.2832)
        if env=="pluck": e=math.exp(-t*6) if t>0.005 else t/0.005
        elif env=="kick": e=math.exp(-t*25)
        elif env=="snare": e=math.exp(-t*18)
        elif env=="hat": e=math.exp(-t*40)
        else: e=((1-tn)/0.2 if tn>0.8 else 1) if t>0.01 else t/0.01
        out.append(val*e*vol)
    return out

def build_audio():
    tracks=[]
    mel=[("G4",0,2),("C5",2,1),("E5",3,1),("D5",4,3),("C5",7,1),("E5",8,2),("D5",10,1),("C5",11,1),("B4",12,2),("A4",14,2),
         ("G4",16,2),("C5",18,1),("E5",19,1),("G5",20,2),("E5",22,2),("D5",24,2),("C5",26,1),("B4",27,1),("C5",28,4),
         ("E4",32,1),("G4",33,1),("A4",34,1),("B4",35,1),("A4",36,1.5),("G4",37.5,0.5),("E4",38,2),
         ("D4",40,1),("E4",41,1),("G4",42,2),("A4",44,2),("G4",46,1),("E4",47,1),
         ("C5",48,1),("B4",49,1),("A4",50,1),("G4",51,1),("E5",52,2),("D5",54,2),("C5",56,2),("B4",58,1),("A4",59,1),("G4",60,4)]
    for rep in range(5):
        off=rep*64
        for n,s,dur in mel: tracks.append((n,off+s,dur,"square",0.12,"sustain"))
    bass=["C3","G3","A3","E3","C3","G3","A3","C3"]
    for rep in range(20):
        for i,bn in enumerate(bass): tracks.append((bn,rep*32+i*4,3.5,"triangle",0.14,"sustain"))
    for i in range(320):
        if i%4==0: tracks.append(("C3",i,0.25,"noise",0.08,"kick"))
        if i%4==2: tracks.append(("E4",i,0.12,"noise",0.06,"snare"))
        if i%2==0: tracks.append(("A4",i+0.5,0.06,"noise",0.03,"hat"))
    return tracks

def mix_tracks(tracks):
    NM={"C3":130.81,"D3":146.83,"E3":164.81,"F3":174.61,"G3":196,"A3":220,"B3":246.94,
        "C4":261.63,"D4":293.66,"E4":329.63,"G4":392,"A4":440,"B4":493.88,
        "C5":523.25,"D5":587.33,"E5":659.25,"G5":783.99}
    bl=60/120; total=int(SR*TOTAL_SEC); mixed=[0.0]*total
    for nm,sb,db,wv,vol,env in tracks:
        freq=NM.get(nm,0); ss=int(sb*bl*SR); dur=db*bl
        if ss>=total: continue
        samples=gen_note(freq,min(dur,TOTAL_SEC-ss/SR),wv,vol,env)
        for i,s in enumerate(samples):
            idx=ss+i
            if idx<total: mixed[idx]+=s
    pk=max(abs(s) for s in mixed) or 1
    return [s/pk*0.7 for s in mixed]

def save_wav(samples,fn):
    with wave.open(fn,'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        for s in samples:
            w.writeframes(struct.pack('<h',int(max(-1,min(1,s))*32767)))

# ═══════ MAIN ═══════
if __name__=="__main__":
    print("=== THE LEGEND OF MEILE — Video Renderer ===")
    print(f"{W}x{H} @ {FPS}fps, {TOTAL_SEC}s")
    os.makedirs(FRAME_DIR,exist_ok=True)
    print("[1/3] Generating audio...")
    tracks=build_audio(); samples=mix_tracks(tracks)
    wav=os.path.join(FRAME_DIR,"ost.wav"); save_wav(samples,wav)
    print(f"  Saved: {wav}")
    total_frames=TOTAL_SEC*FPS
    print(f"[2/3] Rendering {total_frames} frames...")
    for i in range(total_frames):
        render_frame(i).save(os.path.join(FRAME_DIR,f"f_{i:05d}.png"))
        if(i+1)%(FPS*5)==0: print(f"  {i+1}/{total_frames} ({(i+1)/total_frames*100:.0f}%)")
    print("[3/3] Encoding MP4...")
    subprocess.run(["ffmpeg","-y","-framerate",str(FPS),"-i",os.path.join(FRAME_DIR,"f_%05d.png"),
                    "-i",wav,"-c:v","libx264","-preset","medium","-crf","18","-c:a","aac","-b:a","192k",
                    "-pix_fmt","yuv420p","-shortest","-movflags","+faststart",OUTPUT],check=True)
    print(f"\n=== DONE: {OUTPUT} ({os.path.getsize(OUTPUT)/1024/1024:.1f} MB) ===")
    shutil.rmtree(FRAME_DIR,ignore_errors=True)
