pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- antsy alien attack pico
-- wimpysworld.com

#include build_config.p8

function _init()
 version_data,version_game="1","1"
 cartdata("wimpy_antsy-alien-attack-pico_"..version_data)
 extcmd("set_title","antsy alien attack pico")

 // persist hi_score
 hi_score=dget(0)
 if hi_score==0 then
  for i=1,7 do
   hi_score+=25000 >> 16
  end
  dset(0,hi_score)
 end

 // 0: new cart
 // 1: on
 //-1: off
 music_enabled=dget(1)
 if music_enabled==0 then
  music_enabled=1
  dset(1,music_enabled)
 end

 ignore_input=0

 num_players=1

 dt,fc,tick,l_tick,sparkle=0,0,0,0,0
 init_attract()
end

function _update60()
 debug={}
 l_tick=tick
 tick=time()
 dt=tick-l_tick
 fc+=1
 ignore_input=max(0,ignore_input-1)

 sparkle+=1
 if (sparkle<=1 or sparkle>15) sparkle=2

 update_loop()
end

function _draw()
 draw_loop()
 add(debug,stat(5))
 cursor(0,12)
 color(7)
 for d in all(debug) do
  print(d)
 end
end
-->8
-- game state & menus

function add_menu_item(name,pos,init)
 add(menu_items,{
  name=name,
  pos=pos,
  col=12,
  out=1,
  init=init
 })
end

function exit_game()
 extcmd("shutdown")
end

function init_attract()
 if not menu_pos then
  menu_pos=1
 else
  sfx(1)
 end
 ignore_input=10
 init_stars()
 update_loop,draw_loop=
  update_attract,draw_attract
 menu_items={}
 add_menu_item("play",40,init_game)
 add_menu_item("music",50,music_toggle)
 add_menu_item("help",60,init_help)
 add_menu_item("credits",70,init_credits)
 if (show_exit) add_menu_item("exit",80,exit_game)  
end

function update_attract()
 stars_accx=0
 stars_accy*=.999

 for i=0,1 do
 local dx,dy=
  get_x_axis(controller),
  get_y_axis(controller)
  
  // integrate starfield accel
  apply_stars_accel(dx,dy)
 end

 update_stars()
 if any_action_btnp() then
  if (menu_pos!=1) sfx(1)
  menu_items[menu_pos].init()
 end

 if any_btnp(2) then
  menu_pos-=1
  sfx(0)
 elseif any_btnp(3) then
  menu_pos+=1
  sfx(0)
 end
 menu_pos=mid(1,menu_pos,#menu_items)

 if any_btnp(0) or any_btnp(1) then
  if (menu_pos==1) num_players+=1
  if (menu_pos==2) music_toggle()
  if (num_players>2) num_players=1
  sfx(1)
 end 
end

function draw_attract()
 local c=nil
 cls(0)
 draw_stars()
 print_fx("antsy alien",nil,2,11,3,3,"big")
 print_fx("attack!",nil,16,8,2,2,"big") 
 print_fx(_puny("pico"),nil,28,7)

 local music_state="off"
 if (music_enabled>=0) music_state="on"
 for i=1,#menu_items do
  local m=menu_items[i]
  if (i==1) m.name="play "..tostr(num_players).."-up"
  if (i==2) m.name="music "..music_state
  if (menu_pos==i) c=sparkle else c=m.col
  print_fx(m.name,nil,m.pos,c,m.out,m.out)

  -- draw hints for toggles
  if i<=2 and i==menu_pos then
   print_fx("⬅️",31,m.pos,sparkle,1,1)
   print_fx("➡️",88,m.pos,sparkle,1,1)
  end
 end
 
 print_fx(_puny("(c) 2023 wimpysworld.com"),nil,120,7,5,5)

 local tux=sprite_create({140},4,4)
 tux.pal_trans=12
 sprite_draw(tux,89,90)
 print_fx(_puny("made with ♥ for"),nil,100,7)
 print_fx(_puny("          ♥    "),nil,100,8,2,14)
 print_fx(_puny("linux game jam"),nil,105,7) 
end

function init_help()
 ignore_input=60
 update_loop,draw_loop=
  update_help,draw_help
end

function update_help()
 update_stars()
 if (any_action_btnp()) init_attract()
end

function draw_help()
 cls(0)
 draw_stars()
 print_fx("                    ",nil,4+8,6,13,13,"invert")
 print_bounce("help",nil,9,10,9,9,16,3)

 local help_text={
  " antsy alien attack pico ",
  "                         ",
  " if it moves shoot first ",
  " and ask questions later ",
  "                         ",
  "  some explosions yield  ",
  " power ups, collect them ",
  "        good luck!       ",
 }

 print_wave(help_text,nil,24,12,1,1)
 menu_footer()
end

function add_credits(name,humans,y,lt,dk)
 add(credits,{
  name=name,
  humans=humans,
  y=y,
  lt=lt,
  dk=dk
 })
end

function init_credits()
 ignore_input=60
 update_loop,draw_loop=
  update_credits,draw_credits
 credits={}
 add_credits("code",    "martin wimpress",3,8,2)
 add_credits("music",   "chris donnelly",27,9,4)
 add_credits("sound",   "chris donnelly & martin wimpress",50,10,9)
 add_credits("graphics","alice masters, krystian majewski & martin wimpress",73,11,3)
 add_credits("testing", "alan pope, neil mcphail, stuart langridge & simon butcher",96,12,1)
end

function update_credits()
 update_stars()
 if (any_action_btnp()) init_attract()
end

function draw_credits()
 cls(0)
 draw_stars()
 for c in all(credits) do
  print_fx("                    ",nil,c.y+6,c.lt,c.dk,c.dk,"invert")
  print_bounce(c.name,nil,c.y+3,6,5,5,8,3)
  print_scroll(c.humans,22,c.y+14,83,c.lt)
 end
 menu_footer()
end

function menu_footer()
 print_fx("press ❎ or 🅾️",nil,120,6)
 print_fx("      ❎    🅾️",nil,120,sparkle)
end

-- menus respond to multiple controllers
function any_btnp(b)
 if (ignore_input>0) return
 return btnp(b,0) or btnp(b,1)
end

function any_action_btnp()
 return any_btnp(4) or any_btnp(5)
end
-->8
-- vfx

function init_stars()
 stars={}
 hyperspeed,hyperspeed_target=0,0

 -- starfield acceleration
 -- can react to player input
 stars_max_accy,
 stars_min_accy=
  3,1

 stars_accx,stars_accy=
  0,stars_min_accy

 for i=1,64 do
  local s=rnd(1)+0.25
  local c=1
  if (s>1) c=13

  add(stars,{
   x=rnd(127),
   y=rnd(127),
   s=s,
   c=c
  })
 end
end

function apply_stars_accel(dx,dy)
 local players=2

 stars_accx+=(dx*0.5)/players

 if dy==-1 then
  stars_accy-=dy*0.05/players
 else
  stars_accy-=0.05/players
 end

 // limit stars min/max accel
 if (stars_accy<stars_min_accy) stars_accy=stars_min_accy
 if (stars_accy>stars_max_accy) stars_accy=stars_max_accy
end

function star_flip_y(y)
 if (y<64) y+=64 else y-=64
 return y
end

function update_stars()
 if hyperspeed_target>hyperspeed then
  hyperspeed+=0.075
 elseif hyperspeed_target<hyperspeed then
  hyperspeed-=0.05
 end

 hyperspeed=max(0,hyperspeed)
 if (hyperspeed_target>=1 and hyperspeed>hyperspeed_target) hyperspeed=hyperspeed_target

 for star in all(stars) do
  if hyperspeed<=0 then
   star.x+=star.s*stars_accx
   if star.x<0 then
    star.x=127
    star_y=star_flip_y(star.y)
   elseif star.x>127 then
    star.x=0
    star_y=star_flip_y(star.y)
   end
  end

  star.y+=star.s+hyperspeed+stars_accy
  if (star.y>127) star.x,star.y=rnd(127),0
 end
end

function draw_stars()
 for star in all(stars) do
  if hyperspeed>=1 then
   local c=star.c
   if (hyperspeed>=2) c=6
   if (hyperspeed>=4) c=13
   line(star.x,star.y,star.x,star.y-hyperspeed,c)
   pset(star.x,star.y,6)
  else
   pset(star.x,star.y,star.c)
  end
 end
end

-- text

function _center(txt)
 return 64-(#txt*(_txt_wide/2))
end

//https://pico-8.fandom.com/wiki/p8scii_control_codes
function _normal(txt)
 txt = txt or ""
 _txt_wide,_txt_high=4,5
 return "\^-w\^-t\^-=\^-p\^-i\^-b\^-#"..txt
end

function _wide(txt)
 _txt_wide=8
 return "\^w"..txt
end

function _tall(txt)
 _txt_high=10
 return "\^t"..txt
end

function _big(txt)
 return _wide(_tall(txt))
end

function _solid(txt)
 return "^\#"..txt
end

function _invert(txt)
 return "\^i"..txt
end

function _dotty(txt)
 return _big("\^p")..txt
end

function _puny(txt)
 local txt_out=""
 for i=1,#txt do
  local c=ord(txt,i)
  txt_out..=chr(c>96 and c<123 and c-32 or c)
 end
 return txt_out
end

function print_fx(txt,x,y,c,lo,hi,style)
 local stxt=_normal(txt)
 if (style=="big")      stxt=_big(txt)
 if (style=="invert")   stxt=_invert(txt)
 if (style=="dotty")    stxt=_dotty(txt)
 if (style=="solid")    stxt=_solid(txt)
 //if (style=="stripy_t") return "\^t\^="
 //if (style=="stripy_w") return "\^w\^="
 if (style=="tall")     stxt=_tall(txt)
 if (style=="wide")     stxt=_wide(txt)
 x = x or _center(txt)

 --highlight
 if hi then
  ?stxt,x-1,y,hi
  ?stxt,x,y-1,hi
 end

 --shadow
 if lo then
  ?stxt,x+1,y,lo
  ?stxt,x,y+1,lo
 end

 ?stxt,x,y,c
end

function print_scroll(txt,x,y,w,c)
 local len=#txt*4+w
 local ox=(tick/dt)%len
 clip(x,y,w,_txt_high)
 print_fx(txt,x+w-ox,y,c)
 clip()
end

function print_bounce(txt,x,y,c,lo,hi,speed,bounce,style)
 x = x or _center(txt)
 for i=1,#txt do
  print_fx(
   txt[i],
   x,
   y+cos(tick+i/speed)*bounce,
   c,
   lo,
   hi,
   style)
  x+=_txt_wide
 end
end

function print_wave(txt,x,y,c,lo,hi,speed,wave,style)
 speed=speed or 0
 wave=wave or 0
 for i=1,#txt do
  if (not x) x=_center(txt[i],_txt_wide)
  print_fx(
   _puny(txt[i]),
   x+sin(tick+i/speed)*wave,
   y,
   c,
   lo,
   hi,
   style)
  y+=_txt_high+1
 end
end

function zero_pad(txt,len)
 if (#txt<len) return "0"..zero_pad(txt,len-1)
 return txt
end

function numtostr(num,pad)
 local txt=tostr(num,0x2)
 if (pad) txt=zero_pad(txt,pad)
 return txt
end
-->8
-- game logic

function init_game()
 gametime=0
 hyperspeed_target=5
 update_loop,draw_loop=
  update_game,draw_game
end

function update_game()
 cls(0)
 gametime+=1
 draw_stars()
 print_fx("hi "..numtostr(hi_score,7),_center("hi 0000000",4),0,7)

 print_bounce("coming june 6th 2023!",nil,60,12,1,1,32,8)

 if hyperspeed<=0 and gametime>=300 then
   update_loop,draw_loop=
    update_attract,draw_attract   
 elseif gametime>=300 then
  hyperspeed_target=0 
 elseif gametime<300 then
  hyperspeed_target=5
 end
end

function draw_game()
 update_stars()
end
-->8
--tab 4
-->8
-- tab 5
-->8
-- helpers

function sprite_create(sprites,w,h)
 return {
  frames=sprites,
  x=-32,
  y=144,
  w=w,
  h=h,
  flip_x=false,
  flip_y,false,
  //hitbox is relative to x,y
  hb_x=0,
  hb_y=0,
  hb_width=8*w,
  hb_height=8*h,
  // calculate half widths/heights
  // used for collision detection
  hb_hw=8*w/2,
  hb_hh=8*w/2,
  emit_x=-32,
  emit_y=144,
  frame=1,
  pal_swaps={},
  pal_trans=0,
  pal_whiteflash=0,
  show_hitbox=false
 }
end

function sprite_draw(s,x,y)
 // update x,y for collision detection
 s.x,s.y=x,y

 // calc where damage emits from
 s.emit_x,s.emit_y=
  s.x+s.hb_hw,
  s.y+s.hb_hh

 // do palette swaps
 // change the transparent col
 if (s.pal_trans!=0) palt(s.pal_trans)

 // make sprite
 if s.pal_whiteflash>0 then
  s.pal_whiteflash-=1
  for i=1,15 do pal(i,7) end
 else
  // color replacements
  for pal_swap in all(s.pal_swaps) do
   pal(pal_swap[1],pal_swap[2])
  end
 end

 spr(s.frames[flr(s.frame)],x,y,s.w,s.h,s.flip_x,s.flip_y)

 // reset palette
 if (#s.pal_swaps or s.pal_trans!=0 or s.pal_whiteflash) pal()

 // useful fordebugging
 if s.show_hitbox then
	 rect(
	  x+s.hb_x,
	  y+s.hb_y,
	  x+s.hb_x+s.hb_width,
	  y+s.hb_y+s.hb_height,
	  sparkle)
 end
end

function music_play(pat)
 if music_enabled>0 then
  music(pat,0,3)
 else
  music(-1,1000,0)
 end
end

function music_toggle()
 music_enabled*=-1
 music_play(max(-1,music_enabled))
 dset(1,music_enabled)
end

function get_x_axis(controller)
 local btn0_mask,btn1_mask=0x0001,0x0002
 if controller==1 then
  btn0_mask,btn1_mask=0x0100,0x0200
 end
 return (btn() & btn1_mask)/btn1_mask-(btn() & btn0_mask)/btn0_mask
end

function get_y_axis(controller)
 local btn2_mask,btn3_mask=0x0004,0x0008
 if controller==1 then
  btn2_mask,btn3_mask=0x0400,0x0800
 end
 return (btn() & btn3_mask)/btn3_mask - (btn() & btn2_mask)/btn2_mask
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccc100001ccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccc00000000cccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc1000000001ccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc0000000000ccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc00700007001cccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc07770077701cccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc07170071701cccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc071f0071f01cccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc00f9999f001cccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc09999999901cccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc00944429d01cccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccc00069999d7005ccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccc0006667777001ccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccc000d6667777001ccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc1000666677777005cccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc000d666777777701cccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc100066677777777005ccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc000066677777777005ccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc000066777777777f01ccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc1000d6677777777f0005cccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc00006667777777f00001cccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc44440666777777f0004444ccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc4999ad6677777700099994ccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc499999ad667777f009999994cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc4999999006677f0009999994cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccc49999999000677f00099999994ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccc49999999000d77f00099999944ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc4999999a0000000099999994cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc4499999011111109999944ccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc44994cccccccc49944ccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccc444cccccccc444ccccccccc
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000333333003333000033333300003333003300330000000000333333003300000033333300333333003333000000000000000000000000
00000000000000000003bbbbbb33bbbb3003bbbbbb3003bbbb33bb33bb3000000003bbbbbb33bb300003bbbbbb33bbbbbb33bbbb300000000000000000000000
00000000000000000003bbbbbb33bbbb3303bbbbbb3033bbbb33bb33bb3000000003bbbbbb33bb300003bbbbbb33bbbbbb33bbbb330000000000000000000000
00000000000000000003bb33bb33bb33bb3033bb3303bb333303bb33bb3000000003bb33bb33bb30000033bb3303bb333303bb33bb3000000000000000000000
00000000000000000003bb33bb33bb33bb3003bb3003bb333303bb33bb3000000003bb33bb33bb30000003bb3003bb330003bb33bb3000001000000000000000
00000000000000000003bbbbbb33bb33bb3003bb3003bbbbbb33bbbbbb3000000003bbbbbb33bb30000003bb3003bbbb3003bb33bb3000000000000000000000
00000000000000000003bbbbbb33bb33bb3003bb3003bbbbbb33bbbbbb3000000003bbbbbb33bb30000003bb3003bbbb3003bb33bb3000000000000000000000
00000000000000000003bb33bb33bb33bb3003bb30003333bb303333bb3000000003bb33bb33bb30000003bb3003bb330003bb33bb3000000000000000000000
00000000000000000003bb33bb33bb33bb3003bb30003333bb303333bb3000000003bb33bb33bb33330033bb3303bb333303bb33bb3100000000000000000000
00000000000000000003bb33bb33bb33bb3003bb3003bbbb3303bbbbbb3000000003bb33bb33bbbbbb33bbbbbb33bbbbbb33bb33bb3000000000000000000000
00000000000000000003bb33bb33bb33bb3003bb3003bbbb3003bbbbbb3000000003bb33bb33bbbbbb33bbbbbb33bbbbbb33bb33bb3000000000000000000000
00000000010000000000330033003300330000330000333310003333330000000000330033003333330033333300333333003300330000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000022222200222222002222220022222200002222002200220000220000000000000000000000000000000000000000
00000000000000000000000000000000000288888822888888228888882288888820028888228822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288888822888888228888882288888820228888228822882002882000000000000000000000000000000000000000
00000000010000000000000000000000000288228820228822002288220288228822882222028822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228822882000028822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288888820028820000288200288888822882000028888220002882000000000000000000000000000000000000000
00000000000000000000000000000000000288888820028820000288200288888822882000028888220002882000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228822882000028822882000220000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228822882222028822882000220000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228820228888228822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228820028888228822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000022002200002200000022000022002200002222002200220000220000000000000000000000000000000000000000
00000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000077077700770077000000000000000000000000000000000000000000000000010000000
00000000000000000000000000000000000000000000000000000000707007007000707000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777007007000707000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000700077700770770000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000
00000000000000000000000000000000000000000000000000000000001110111000001000111000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000001011cc11ccc10001c101ccc110100000000000000000000000000000000000000000000000
100000000010000000000000000000000000000000000000001111c1c1c1c1c1100001c1101c11c1c10000000000000000000000000000010000000000000000
00000000000000000000000000000000000000000000000001ccc1c1c1c1c1cc100001ccc11c11c1c10000111000000000000000000000000000000000000000
000000000000000000000000000000000000000000011000001c11c1c1c1c1c1100001c1c11c11ccc10001ccc100000000000000000000000000000000000000
0000000000000000000000000000000000000000001cc100001c11c1c1c1c1ccc10001ccc11c11c1c1000011c111100000000000000000000000000000000000
000000000000000000000000000000000000001101c11000001c101cc110101110000011100101c1c10001ccc1ccc11110000000000000000000000000000000
00000000000000000000000000000000001111cc11c1100001cc100110000d000000000000000010100001c111c1c1ccc1000000000000000000000000000000
0000000000001000000000000000000001ccc1c1c1c1c10000110000000000000000000000000000000001ccc1c1c111c1111000000000000000000000000000
00000000000000000000000000000011101c11c1c1ccc100000000000000000000000000000000000000001111c1c1ccc1ccc101000000000000000000000000
000000000000000000000000000111ccc11c11c1c1111000000000000000000000000000000000000000000001ccc1c11011c11c100000000000010000000000
000000000000000000000000001cc1ccc11c11c1c10000000000000000000000000000000000000000000000001111ccc11cc11c100000000000000000000000
00000000000000000000000111c1c1c1c1ccc110100000000000000000000000000000000000000000000000000000111011c11c100000000000000000000000
00000000000000000000001cc1c1c1c1c11110000000000000000000000000000000000000000000000000000000000001ccc101000000000000000000000000
0000000000000000000001c111c1c1c1c1000000000000000000000000000000000000000000000000000000000000000011101c100000000000000000000000
0000000000000000000001c101cc1010100000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000
0000000000000000000001c110110000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000
00000000000000000000001cc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000100001000000000000
00000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100
00000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000100000000000000000000
00000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000001000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000700100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777007770100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000717007170100000000000000000
0000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000071f0071f0100000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000ee0ee0000000000000000000000f9999f00100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000e88288200000000000000000000999999990100000000000000000
00000000000010000000000000000000007770077077007770000070707770777070700000e88888200000777007707700000094442900100000000000000000
00000000000000000000000000000000007770707070707700001070700700070070700000e88888200000770070707070000069999070050000000000000000
000000000000000000000000000d0000007070777070707000000077700700070077700000028882000000700070707700000066677770010000000000000000
00000000000000000000000000000000007070707077000770000077707770070070700000002820000000700077007070000066677770010000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000001000666677777005000000000000000
00000000000000000000000000000000000070007770770070707070000007700770777077700000777017707770000000000666777777701000000000000000
00000000000000000000000001010000000070000700707070700700000070007070777077000000070070707770000010006667777777700500000000000000
00000000000000000000000000000000000070000700707070700700000070707770707070000000070077707070000000006667777777700500000000000000
000000000000000000000000000000000000077077707070077070700000777070707070077000007700707070700000000066777777777f01000000d0000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100006677777777f00050000000000000
0000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000006667777777f000010000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440666777777f0004444000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004999a06677777700099994000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000499999a0667777f00999999400000000000
000000000000000000000000000000000000000000000000d000000000000000010000000000000000000000000004999999006677f000999999400000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049999999000677f000999999940000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001049999999000077f000999999440000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004999999a000000009999999400000000000
00000000000010000500000005000000555055505550555000000000000000000000000000000000000000000000004499999011111109999944000000000000
00000000000000005750055057500005777577757775777500005050555055500550505005505050055055005000550044994550055054994400000000000000
00000000000000057500577505750000557575755575557500057575777577755775757557757575577577557505775000444775577574440000000000000000
00000000000000057505755005750005777575757775577500057575575577757575777575557575757575757505757500057555757577750000000000000000
00000000000000057505755005750005755575757550557500057775575575757775557555757775757577557555757505057555757575750000000000000000
00000000000000005750577557500005777577757775777500057775777575757555775577557775775575755775775057505775775575750000000000000000
00000000000000000500055005000000555055505550555000005550555050505000550055005550550050500550550005000550550050500000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

