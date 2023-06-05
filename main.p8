pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- antsy alien attack pico
-- wimpysworld.com

#include build_config.p8

function _init()
 missions,
 debris_red,
 debris_green,
 debris_fire,
 fc,
 ignore_input,
 num_players,
 pickup_base,
 screen_flash,
 screen_shake,
 sparkle,
 version_data=
  {
   "players_off,jump",
   //1
   "level_in,fly_in,players_on,drop,drone,wait,bronze,wait,asteroid_belt,wait,silver,wait,pass_some,wait,metal,level_out,players_off,jump,fly_out",
   //2
   "level_in,fly_in,players_on,drop,sapphire,wait,quick_shoot,wait,cargo_in,cargo_game,cargo_out,wait,jump,weapons_off,power_spree,wait,asteroid_belt,wait,weapons_on,drop,emerald,level_out,players_off,jump,fly_out",
   //3
   "level_in,fly_in,players_on,drop,gem,wait,jump,weapons_off,quick_force,wait,spheres,wait,asteroid_belt,wait,power_spree,wait,weapons_on,drop,metal,level_out,players_off,jump,fly_out",
   //4
   "level_in,fly_in,players_on,drop,gem,wait,pass_none,wait,quick_shoot,wait,spheres,wait,asteroid_belt,wait,jump,weapons_off,power_spree,weapons_on,level_out,players_off,fly_out",
   //5
   "level_in,fly_in,players_on,drop,armada,wait,cargo_in,cargo_game,cargo_out,wait,armada,wait,jump,weapons_off,asteroid_belt,wait,power_spree,wait,weapons_on,drop,armada,wait,level_out,players_off,jump,fly_out",
   "drop",
  }, 
  "14,14,8,8,2,2",
  "10,11,11,11,3,3",
  "10,9,9,8,8,2",
  0,
  1,
  1,
  666,
  0,
  0,
  4,
  "2"

 cartdata("wimpy_antsy-alien-attack-pico_"..version_data)
 extcmd("set_title","Antsy Alien Attack Pico")

 // persist hi_score
 hi_score=dget(0)
 if hi_score==0 then
  for i=1,100 do
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

 init_attract()
end

function _update60()
 //supress pico-8 menu
 if (native_build) poke(0x5f30,1)

 fc+=1
 sparkle=rnd_range(6,15)
 ignore_input=max(0,ignore_input-1)

 //update screen shake
 if (screen_shake>10) screen_shake*=0.95 else screen_shake-=1
 screen_shake=mid(0,screen_shake,24)

 update_stars()
 update_loop()
end

function _draw()
 //clear and shake the screen
 if screen_flash>0 then
  screen_flash=max(0,screen_flash-1)
  cls(9)
 else
  cls()
 end
 local shakex,shakey=
  rnd(screen_shake)-(screen_shake/2),rnd(screen_shake)-(screen_shake/2)
 camera(shakex,shakey)

 draw_stars()
 draw_loop()
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
 ignore_input,victory=
  15,
  false
 music_play(0)
 init_stars()
 update_loop,draw_loop=
  update_attract,draw_attract
 menu_items={}
 local menu_y=48
 if (native_build) menu_y=44
 add_menu_item("play",menu_y,init_game)
 add_menu_item("music",menu_y+10,music_toggle)
 add_menu_item("help",menu_y+20,init_help)
 add_menu_item("credits",menu_y+30,init_credits)
 if (native_build) add_menu_item("exit",menu_y+40,exit_game)
end

function update_attract()
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
 print_fx("antsy alien",nil,2,11,3,10,"big")
 print_fx("attack!",nil,16,8,2,14,"big")
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
 palt(12)
 spr(unpack_split"140,89,90,4,4")
 pal()

 print_fx(_puny("made with   for"),nil,100,7)
 spr(unpack_split"15,72,100,1,1")
 print_fx(_puny("linux game jam"),nil,106,7)
end

function init_game_end(status)
 hyperspeed_target=0
 ignore_input=60
 victory=status
 gamestate={}
 
 if (victory) music_play(18) else music_play(0)
end

function draw_game_end()
 local outcome,message,col,dark,spr_num="game over","valiant effort",8,2,78
 if (victory) outcome,message,col,dark,spr_num="well done","planet earth is saved",11,3,110

 draw_hud() 
 print_fx(message,nil,24,col,dark,dark)
 print_bounce(outcome,nil,60,col,nil,nil,34,8,"dotty")
 spr(spr_num,63-8,34,2,2) 

 if hi_player>0 then
  print_fx(tostr(hi_player).."-up new hi-score!",nil,89,7,5,5)
  print_fx(numtostr(hi_score,8),nil,97,sparkle,1,1)
 end
 
 menu_footer()
end

function init_help()
 ignore_input,
 update_loop,
 draw_loop=
  15,
  update_any_action_btnp,
  draw_help
end

function draw_help()
 print_bounce("h e l p",nil,5,11,3,3,32,4)

--[[
 local help_text={
  "the year is 2139.planet earth is",
  "under attack by antsy aliens!---",
  "",
  "one ship. one life. one mission.",
  "",
  "shoot or collide with aliens    ",
  "weapons go offline at hyperspeed",
  "power-ups enhance your ship     ",
  "power-ups charge the dynamo     ",  
  "a full dynamo boosts shields 50%",
 }
--]]

 local help_text=split"the year is 2139.planet earth is,under attack by antsy aliens!, ,one ship. one life. one mission., ,shoot or collide with aliens,weapons go offline at hyperspeed,power-ups enhance your ship,power-ups charge the dynamo,full dynamo adds 50% ship health"

 local y=17
 for i=1,#help_text do
  print_fx(
   _puny(help_text[i]),
   0,
   y,
   12,
   1,
   1)
  y+=7
 end
 spr(unpack_split"110,56,99,2,2")
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
 credits,
 ignore_input,
 update_loop,
 draw_loop=
  {},
  15,
  update_any_action_btnp,
  draw_credits

 //add_credits("code",    "martin wimpress",3,8,2)
 add_credits(unpack_split"code,martin wimpress,3,8,2") 
 add_credits(unpack_split"music,chris donnelly,27,9,4")
 add_credits(unpack_split"sound,chris donnelly + martin wimpress,50,10,9")
 add_credits(unpack_split"graphics,alice masters + krystian majewski + martin wimpress,73,11,3")
 add_credits(unpack_split"testing & design,alan pope + neil mcphail + stuart langridge + roger light + simon butcher + martin wimpress,96,12,1")
end

function draw_credits()
 for c in all(credits) do
  print_fx("                    ",nil,c.y+6,c.lt,c.dk,c.dk,"invert")
  print_bounce(c.name,nil,c.y+3,6,5,5,8,3)
  print_scroll(c.humans,0,c.y+14,127,c.lt)
 end
 menu_footer()
end

function update_any_action_btnp()
 if (any_action_btnp()) init_attract()
end

function menu_footer()
 print_fx("❎ or 🅾️  ",nil,120,6)
 print_fx("❎    🅾️  ",nil,120,sparkle)
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

function emit_debris(x,y,size,style)
 style = style or debris_fire
 col=split(style)[rnd_range(1,6)]

 for i=1,10 do
  add(debris,{
   x=x,
   y=y,
   sx=rnd_range(-2.5,2.5,true),
   sy=rnd_range(-0.8,0.8,true),
   col=col,
   decay=10
  })
  end
end

function update_debris()
 for d in all(debris) do
  d.sy-=0.2
  d.x+=d.sx
  d.y+=d.sy
  d.decay-=0.5
  if (d.decay<=0) del(debris,d)
 end
end

function draw_debris()
 for d in all(debris) do
  pset(d.x,d.y,d.col)
 end
end

function emit_shockwave(x,y,size)
 add(shockwaves,{
  x=x,
  y=y,
  spd=0.95,
  radius=0,
  target_radius=size*10,
  col=6
 })
end

function update_shockwaves()
 for sw in all(shockwaves) do
  sw.radius+=sw.spd
  if (sw.radius>sw.target_radius/2) sw.col=13
  if (sw.radius>=sw.target_radius) del(shockwaves,sw)
 end
end

function draw_shockwaves()
 for sw in all(shockwaves) do
  oval(
   sw.x-sw.radius,
   sw.y-sw.radius/4,
   sw.x+sw.radius,
   sw.y+sw.radius/4,
   sw.col
  )
 end
end

function emit_plume(x,y,wait,maxage,max_radius,spread,style)
 for i=1,rnd_range(1,5) do
  local dist=rnd(spread)+i
  style = style or rnd_range(1,3)

  add(explosions,{
   x=x+sin(dist)*dist/2,
   y=y+cos(dist)*dist/2,
   r=3,
   tor=max_radius*0.75+rnd(max_radius*0.25),
   tox=x+sin(dist)*dist,
   toy=y+cos(dist)*dist,
   wait=wait,
   maxage=maxage,
   at_end="collapse",
   spd=2,
   age=0,
   style=style
  })
 end
end

function emit_explosion(x,y,size,explosion_style,debris_style)
 if (#explosions>40) return

 local wait=size*3+(3/size)
 local max_radius,spread,maxage=
  wait+size,
  rnd_range(size,size*7.5,true),
  rnd_range(wait,wait*2,true)

 emit_debris(x,y,size,debris_style)
 emit_shockwave(x,y,size)

 --x,y,wait,maxage,max_radius,spread
 emit_plume(x,y,wait,maxage,max_radius,spread,explosion_style)
 emit_plume(x,y,wait,maxage,max_radius,spread,explosion_style)
 if (size>=2)	emit_plume(x,y,wait,maxage,max_radius,spread,explosion_style)
 if (size>=3) emit_plume(x,y,wait,maxage,max_radius,spread,explosion_style)
end

function update_explosions()
 for ex in all(explosions) do
  if ex.wait then
   ex.wait-=0.95
   if (ex.wait<=0)	ex.wait=nil
  else
   ex.age+=0.85

   if ex.sx then
    ex.x+=ex.sx
    ex.y+=ex.sy
    if ex.tox	then
     ex.tox+=ex.sx
     ex.toy+=ex.sy
    end
   end

   --cloud rate of collapse
   if (ex.tor) ex.r+=ex.tor-ex.r*ex.spd/1.25

   if ex.tox then
    ex.x+=(ex.tox-ex.x)/ex.spd/250
    ex.y+=(ex.toy-ex.y)/ex.spd/500
   end

   //clouds drift upwards
   ex.y-=0.85

   --max age
   if ex.age>=ex.maxage or ex.r<1 then
    if ex.at_end=="collapse" then
     ex.maxage+=300
     ex.at_end,
     ex.tor,
     ex.spd,
     ex.wait=
      nil,
      0,
      0.2,
      0
    else
     del(explosions,ex)
    end
   end
  end
 end
end

function draw_explosions()
 for ex in all(explosions) do
  if (not ex.wait) then
   local r=ex.r
   local layer,style={
    0,
    r*0.05,
    r*0.17,
    r*0.35,
    r*0.60
   },
   {
    "1,4,9,10,7",  --yellow
    "5,4,9,10,15", --orange
    "1,4,8,9,10",  --fire
    "1,5,13,6,7",  --smoke
    "1,2,8,14,7",  --red
    "1,3,11,10,7", --green
    "1,13,12,6,7"  --blue
   }

   for i=1,#layer do
    //3 is the radius
    circfill(
     ex.x,
     ex.y-layer[i],
     r-layer[i],
     split(style[ex.style])[i]
    )
   end
  end
 end
end

function init_stars()
 stars,
 hyperspeed,
 hyperspeed_target,
 -- starfield acceleration
 -- can react to player input 
 stars_max_accy,
 stars_min_accy,
 stars_accx,
 stars_accy,
 stars_min_accy=
  {},
  0,
  0,
  3,
  1,
  0,
  1

 for i=1,64 do
  local s,c=
   rnd_range(0.25,1.25,true),
   1
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
 local players=active_players()

 stars_accx-=dx*0.5/players

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
    star.x,star.y=
     127,
     star_flip_y(star.y)
   elseif star.x>127 then
    star.x,star.y=
     0,
     star_flip_y(star.y)
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
 _txt_wide,_txt_high=4,5
 return "\^-w\^-t\^-=\^-p\^-i\^-b\^-#"..tostr(txt)
end

function _big(txt)
 _txt_wide,_txt_high=8,10
 return "\^t\^w"..txt
end

function _invert(txt)
 return "\^i"..txt
end

function _dotty(txt)
 _big(txt)
 return "\^t\^w\^p"..txt
end

function _puny(txt)
 local txt_out=""
 for i=1,#txt do
  local c=ord(txt,i)
  txt_out..=chr(c>96 and c<123 and c-32 or c)
 end
 return txt_out
end

function style_text(txt,style)
 if (not style)         return _normal(txt)
 if (style=="big")      return _big(txt)
 if (style=="invert")   return _invert(txt)
 if (style=="dotty")    return _dotty(txt)
end

function print_fx(txt,x,y,c,lo,hi,style)
 local stxt=style_text(txt,style)
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
 local ox=(time()/0.03)%len
 clip(x,y,w,5)
 print(txt,x+w-ox,y,c)
 clip()
end

function print_bounce(txt,x,y,c,lo,hi,speed,bounce,style)
 //this just gets the font
 //dimensions
 style_text(txt,style)
 x = x or _center(txt)
 for i=1,#txt do
  print_fx(
   sub(txt,i,i),
   x+(i*_txt_wide)-_txt_wide,
   y+sin(time()+i/speed)*bounce,
   c,
   lo,
   hi,
   style)
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

function init_missions()
 objectives_total,
 objectives_progress,
 current_mission,
 current_objective,
 level,
 objective_complete=
  0,
  0,
  0,
  0,
  0,
  false

 local m=0
 for mission in all(missions) do
  m+=1
  for objective in all(split(mission)) do
   if (m>1 and m<#missions) objectives_total+=1
  end
 end
end

function objective_cleanup()
 emit_smartbomb()
 for pl in all(players) do
	 if (pl.hp>0) apply_generator_charge(pl,10)
 end
 objective_complete=true
end

function draw_shmup()
 if (level>1) return

 if gamestate.gametime<600 then
  local x_off,spr_num,spr_off,flip_h=8,42,0,false
  for pl in all(players) do
   if (pl.num==2) x_off,spr_num,spr_off,flip_h=0,43,23,true
   print_fx(_puny("health"),pl.hud_x+x_off,8,pl.col_lt)
   print_fx(_puny("dynamo"),pl.hud_x+x_off,13,12)    
   spr(spr_num,pl.hud_x+spr_off,6,1,2,flip_h)
  end
  print_fx(_puny("progress"),nil,8,10)
  spr(57,41,6,1,1)
  spr(57,78,6,1,1,true)
 end
end

function shmup(fleet)
 //armada is the default.
 local spawn,title,rate=
  split"asteroid,drone,orby,bronze,silver,sapphire,emerald,silver,sapphire,emerald,silver,sapphire,emerald",
  "armada!",
  15
 if fleet=="drone" or
    fleet=="bronze" or
    fleet=="silver" or    
    fleet=="sapphire" or
    fleet=="emerald" then
  spawn,title=
   {},
   fleet.." party"
  for i=1,level do
   add(spawn,fleet)
  end
 elseif fleet=="spheres" then
  spawn,title=
   split"drone,orby",
   "sphere them!"
 elseif fleet=="metal" then
  spawn,title=
   split"bronze,silver",
   "metal squad"
 elseif fleet=="gem" then
  spawn,title=
   split"sapphire,emerald",
   "gem squad"
 end

 if fleet!="spheres" and fleet!="armada" then 
	 if level>=2 then
	  add(spawn,"drone")
	  title=fleet.." scouts"
	 end
	 if level>=3 then
	  add(spawn,"orby")
	  title=fleet.." raiders"
	 end
	 if level>=4 then
	  add(spawn,"asteroid")
	  title=fleet.." hunters"
	 end
	end
 
 local win_target=level*25
 if (evade) win_target=750+level*250

 if not gamestate.ready then
  gamestate.hud_target,
  gamestate.aliens_max,
  gamestate.title,
  gamestate.text,
  gamestate.draw=
   win_target,
   level+5,
   title,
   "destroy "..tostr(win_target).." aliens",
   draw_shmup
  if evade then
   rate,
   gamestate.aliens_max,
   gamestate.text=
    30,
    2+level*3,
    "evasive manoeuvres only!"
  end
 else
  if #aliens<gamestate.aliens_max and one_in(rate) then
   local al=create_alien(rnd_range(16,112),rnd_range(-16,-8),spawn[rnd_range(1,#spawn)])
   if (al and fleet=="armada") then
    al.hp+=20
    al.speed_y+=0.55
   end
  end

  if evade then
   gamestate.hud_progress=gamestate.gametime
   if gamestate.gametime>=win_target then
    objective_cleanup()
   end
   if (one_in(175)) create_pickup(rnd_range(52,76),-8,true)
  else
   gamestate.hud_progress=gamestate.aliens_destroyed
   if gamestate.aliens_destroyed>=win_target then
    objective_cleanup()
   end
  end
 end
end

function draw_pass()
 spr(81,0,125)
 spr(82,120,125)
 line(3,126,124,126,sparkle)
end

function pass(can_pass)
 local win_target=1000+level*100
 if not gamestate.ready then
  gamestate.hud_target,
  gamestate.draw,
  gamestate.aliens_max,
  gamestate.title,
  gamestate.text=
   win_target,
   draw_pass,
   level*2,
   "none shall pass",
   "you must stop them all!"
  if can_pass then
   gamestate.aliens_max,
   gamestate.title,
   gamestate.text=
   level*3,
    "some can pass",
    "try and stop them all!"
  end
 else
  gamestate.hud_progress=gamestate.gametime
  if gamestate.gametime>=win_target then
   objective_cleanup()
  end  
  if #aliens<gamestate.aliens_max and one_in(15) then
   // narrow the x range for
   // none shall pass
   local spawn_x=rnd_range(28,100)
   if (can_pass) spawn_x=rnd_range(20,108)
   create_alien(spawn_x,-8,"orby")
  end

  for al in all(aliens) do
   al.speed_y+=0.002
   if al.y>=128 then
    gamestate.aliens_escaped+=1
    for pl in all(players) do
     if can_pass then
      apply_player_damage(pl,al.collision_damage)
     else
      // none shall pass insta-death
      apply_player_damage(pl,pl.hp+10)
     end
    end
    del(aliens,al)
   end
  end
 end
end

function asteroid_belt()
 local win_target=1000+level*250
 if not gamestate.ready then
  local max_rocks,title,text=32,"asteroid belt","get your rocks off baby"
  if (evade) max_rocks,title,text=24,"fly to survive","rocks in a hard place"
  
  gamestate.hud_target,
  gamestate.aliens_max,
  gamestate.title,
  gamestate.text=
   win_target,
   max_rocks,
   title,
   text
 else
  gamestate.hud_progress=gamestate.gametime

  if evade then
   local startx=8
   if (fc%2==0) startx=108
   if (one_in(250)) create_pickup(rnd_range(startx,startx+16),-8,true)
  end
  
  if #aliens<gamestate.aliens_max and one_in(3) then
   local al=create_alien(rnd_range(2,126),-8,"asteroid")
   if (al and evade) al.speed_y+=0.35 else al.hp*=0.6
  end

  score_update_all(10*level)

  if gamestate.gametime>=win_target then
   objective_cleanup()
  end
 end
end

function power_spree()
 if not gamestate.ready then  
  gamestate.hud_target,
  gamestate.aliens_max,
  gamestate.title,
  gamestate.text=
   600,
   5,
   "power spree",
   "grab what you can"
 else
  gamestate.hud_progress=gamestate.gametime

  if (one_in(15)) create_pickup(rnd_range(4,120),-8,true)
  
  if #aliens<gamestate.aliens_max and one_in(5) then
   al=create_alien(rnd_range(2,126),-8,"asteroid")
   if (al) al.speed_y+=1.9
  end

  for pu in all(pickups) do
   pu.origin_y+=0.25+hyperspeed/4
  end

  if gamestate.gametime>=600 then
   objective_cleanup()
  end
 end
end

function draw_quick_play()
 print_fx(tostr(gamestate.aliens_destroyed),nil,10,10,9,9)
end

function quick_play(use_the_force)
 if use_the_force then
  time_limit=1000
  win_target=20
 else
  time_limit=900
  win_target=30
 end
 if not gamestate.ready then  
  gamestate.hud_target,
  gamestate.title,
  gamestate.text,
  gamestate.draw=
   time_limit,
   "quick draw",
   "tick. tock. destroy "..tostr(win_target).." aliens",
   draw_quick_play
  if (use_the_force) gamestate.title="use the force"
 else
  gamestate.hud_progress=min(gamestate.gametime,time_limit)
  
  if #aliens<3 and one_in(3) then
   local al=create_alien(rnd_range(32,112),-8,"silver")
   if al then
    al.speed_y+=0.5
    al.hp/=3
   end
  end

  if gamestate.aliens_destroyed>=win_target then
   objective_cleanup()
  end

  if gamestate.gametime>=time_limit then
   for pl in all(players) do
    if (pl.hp<=0) goto already_dead
    // insta-death
    apply_player_damage(pl,pl.hp+10,4,true)
    ::already_dead::
   end
  elseif use_the_force then
   for pl in all(players) do
    if (pl.hp>0) pl.shields=120
   end
  end  
 end
end

function draw_cargo()
 sprite_draw(gamestate.sprite,55,gamestate.y)
end

function cargo(mode)
 local win_target=1000+level*250
 if not gamestate.ready then
  gamestate.draw,
  gamestate.sprite=
   draw_cargo,
   sprite_create({13},2,4)

  if mode=="cargo_in" then
   gamestate.y,
   gamestate.y_target=
    129,
    82
  elseif mode=="cargo_out" then
   gamestate.y,
   gamestate.y_target=
    82,
    -32
  else
   gamestate.hud_target,
   gamestate.aliens_max,
   gamestate.title,
   gamestate.text,
   gamestate.y=
    win_target,
    level+10,
    "cargo run",
    "protect the cargo ship",  
    82
  end

  sprite_hitbox(gamestate.sprite,2,6,11,22)
 else
  if mode=="cargo_game" then
	  gamestate.hud_progress=gamestate.gametime
	  if #aliens<gamestate.aliens_max and one_in(3) then
	   local spawn="asteroid"
	   if (one_in(4)) spawn="bronze"
	   create_alien(rnd_range(2,126),-8,spawn)
	  end
	
   score_update_all(20*level)

   local player_damage=0
	  for al in all(aliens) do
	   if sprite_collision(gamestate.sprite,al.sprite) then
  	  player_damage+=al.collision_damage\2
     emit_explosion(63,al.y+4,3,nil,1)
	    del(aliens,al)
	   end
	  end

   for bl in all(bullets) do
    if sprite_collision(gamestate.sprite,bl.sprite) then
     sound_play(5)
     emit_explosion(63,bl.y+4,1,nil,1)
     player_damage+=bl.damage
     del(bullets,bl)     
    end
   end

   for pl in all(players) do
    if (player_damage>0) apply_player_damage(pl,player_damage,player_damage\2)
   end

	  if gamestate.gametime>=win_target then
	   objective_cleanup()
	  end
	 else
	  gamestate.y-=1
   if (gamestate.y<=gamestate.y_target) objective_complete=true
	 end
 end
end

function autopilot(mode)
 local target_y=-32
 if (mode=="fly_in") target_y=96

 if mode=="fly_in" and not gamestate.ready then
  players_startx()
  gamestate.ready=true
 else
  //autopilot
  for pl in all(players) do
   pl.y-=1
  end

  //arrived at destination?
  if players[#players].y<=target_y then
   objective_complete=true
  end
 end
end

function level_status(mode)
 if not gamestate.ready then
  gamestate.ready,
  gamestate.show_weapons=
   true,false

  gamestate.title="zone "..tostr(level).." of "..#missions-2
  if mode=="level_out" then
   gamestate.title="zone "..tostr(level).." cleared"
   score_update_all(level*5000)
  end
 elseif gamestate.gametime>150 then
  objective_complete=true
 end
end

function draw_wait()
 print_fx("total progress",nil,56,6,5,5)
 local progress=round(objectives_progress/objectives_total*100)
 if (level==#missions-2) progress=100
  
 rectfill(13,63,115,65,9)
 line(14,64,progress+14,64,10)
end

function wait()
 gamestate.draw=draw_wait
 if gamestate.gametime>180 and #explosions<=0 then
  objective_complete=true
 end
end

function jump()
 hyperspeed_target=5
 if hyperspeed>=hyperspeed_target then
  objective_complete=true
 end
end

function drop()
 hyperspeed_target=0
 if hyperspeed<=hyperspeed_target then
  objective_complete=true
 end
end

function init_game()
 aliens,
 bullets,
 pickups,
 rockets,
 debris,
 shockwaves,
 explosions,
 pickup_timer,
 pickup_payloads,
 evade,
 hi_player=
  {}, //aliens
  {}, //bullets
  {}, //pickups
  {}, //rockets
  {}, //debris
  {}, //shockwaves
  {}, //explosions
  pickup_base,
  split"96,97,98,112,113,114",
  false,
  0

 music_play(6)
 init_players()
 init_missions()
 get_next_mission()
 update_loop,draw_loop=
  update_game,draw_game
end

function update_game()
 if objective_complete then
  if #objectives>current_objective then
   get_next_objective()
  elseif current_objective==#objectives then
   if #missions>current_mission then
    get_next_mission()
   elseif current_mission==#missions then
    init_game_end(true)
   end
  end
 end

 if gamestate.ready then
  gamestate.gametime+=1
  gamestate.aliens_jammed=max(0,gamestate.aliens_jammed-1)
 end

 update_players()
 update_rockets()
 update_pickups()

 update_aliens()
 update_bullets()

 //execute game logic
 if (objective=="players_on") activate_players(true)
 if (objective=="players_off") activate_players()
 if (objective=="weapons_on") activate_weapons(true)
 if (objective=="weapons_off") activate_weapons()
 if (objective=="jump") jump()
 if (objective=="drop") drop()
 if (objective=="wait") wait()
 if (objective=="pass_some") pass(true)
 if (objective=="pass_none") pass()
 if (objective=="asteroid_belt") asteroid_belt()
 if (objective=="power_spree") power_spree() 
 if (objective=="quick_shoot") quick_play()
 if (objective=="quick_force") quick_play(true)

 if objective=="level_in" or
    objective=="level_out" then
    level_status(objective)
 end

 if objective=="fly_in" or
    objective=="fly_out" then
    autopilot(objective)
 end

 if objective=="cargo_game" or
    objective=="cargo_in" or
    objective=="cargo_out" then
    cargo(objective)
 end

 if objective=="drone" or
    objective=="bronze" or
    objective=="silver" or
    objective=="sapphire" or
    objective=="emerald" or
    objective=="spheres" or
    objective=="metal" or
    objective=="gem" or    
    objective=="armada" then
  shmup(objective)
 end

 update_shockwaves()
 update_debris()
 update_explosions()

 if active_players()<1 and #explosions<1 then
  init_game_end(false)
 end
end

function draw_game()
 local objects={
  bullets,
  aliens,
  rockets,
  pickups,  
 }

 for object in all(objects) do
  for o in all(object) do
   sprite_draw(o.sprite,o.x,o.y)
  end
 end

 //mini-game specific draws
 if (gamestate.draw) gamestate.draw()

 draw_players()
 draw_hud()

 draw_shockwaves()
 draw_debris()
 draw_explosions()

 //mini-game mission brief
 draw_mission()
end

function create_gamestate()
 return {
  aliens_destroyed=0,
  aliens_escaped=0,
  aliens_jammed=0,
  aliens_max=0,
  player_pickups=0,
  hud_progress=0,
  hud_target=nil,
  gametime=0,
  mission_report_time=0,
  ready=false,
  title="",
  text="",
  show_weapons=true,
  draw=nil
 }
end

function get_next_objective()
 objectives_progress+=1
 current_objective+=1

 //initialise game state
 objective_complete,
 aliens,
 bullets=
  false,
  {},
  {}
 objectives=split(mission)
 objective=objectives[current_objective]
 gamestate=create_gamestate()
 reset_pickup_timer()
end

function get_next_mission()
 current_mission+=1
 current_objective,
 level=
  0,
  min(#missions-2,current_mission-1)
 
 mission=missions[current_mission]
 get_next_objective()
end

//control when players respond
//to input
function activate_players(status)
 for pl in all(players) do
  pl.lock_to_screen,
  pl.controls_enabled=status,status
 end
 activate_weapons(status)
 objective_complete=true
end

function activate_weapons(status)
 for pl in all(players) do
  pl.shot_enabled=status
 end
 evade=not status
 objective_complete=true 
end

function draw_mission()
 if gamestate.mission_report_time<240 and #gamestate.title>0 then
  gamestate.mission_report_time+=1
  if gamestate.text=="" then
    print_fx(gamestate.title,nil,56,9,4,10,"big")
  else
    print_fx(gamestate.title,nil,50,12,1,6,"big")
    print_fx(_puny(gamestate.text),nil,62,6,5,5)
  end
  local txt,col,out="weapons online",11,3
  if not players[#players].shot_enabled then
   txt,col,out="weapons offline",8,2
  end
  if (gamestate.show_weapons) print_fx(_puny(txt),nil,69,col,out,out)
 else
  gamestate.ready=true
 end
end
-->8
-- players

function emit_rocket(player_num)
 emit_muzzle_flash(player_num)
 local pl=players[player_num]

 for i=0,pl.shot_pattern do
  // x_offset is used to adjust
  // the emit point
  // this is for the basic weapon
  local x_offset=0
  if (i>0) x_offset=8
  // spread shot x offset  
  if (pl.shot_pattern>1) x_offset=4

  add(rockets,create_projectile(pl,pl.x+x_offset,pl.y-4))
  local rocket=rockets[#rockets]
  rocket.owner=player_num
  rocket.sprite=sprite_create(pl.rocket_sprites,1,2)
  sprite_hitbox(rocket.sprite,0,1,7,10)
  //rocket.sprite.show_hitbox=true

  // apply pattern
  if pl.shot_pattern>1 then  
   // 3-way  
   local dir,spread,spd=
    0.215,0.04,2.5

   if pl.shot_pattern==3 then
    // 4-way
    dir,spread,spd=
     0.175,0.05,2
   elseif pl.shot_pattern>=4 then
    // 5-way
    dir,spread,spd=
     0.175,0.04,1.75
   end
  
   local ang=dir+((spread+fc)*i)
   rocket.speed_x=cos(ang)*spd
   rocket.speed_y=sin(ang)*spd
  end
 end
end

function check_rocket_collision(rocket)
 local pl=players[rocket.owner]
 for al in all(aliens) do
  if sprite_collision(rocket.sprite,al.sprite) then
   al.hp-=rocket.damage
   if al.hp<=0 then
    //sfx
    gamestate.aliens_destroyed+=1
    score_update(pl,al.reward)
    emit_explosion(al.sprite.emit_x,al.sprite.emit_y,al.explosion_size,nil,pl.debris_style)
    screen_shake+=al.explosion_size+1
    create_pickup(al.sprite.emit_x,al.sprite.emit_y)
    sfx(5+al.explosion_size)
    del(aliens,al)
   else
    emit_debris(al.sprite.emit_x,al.sprite.emit_y,al.debris_size,pl.debris_style)
    al.y-=2
    al.sprite.pal_whiteflash=2
    sound_play(5)
   end
   del(rockets,rocket)
  end
 end
end

function update_rockets()
 for rocket in all(rockets) do
  sprite_loop_frame(rocket.sprite,0.5)
  rocket.x+=rocket.speed_x
  rocket.y+=rocket.speed_y
  if is_outside_playarea(rocket.x,rocket.y) then
   del(rockets,rocket)
  else
   check_rocket_collision(rocket)
  end
 end
end

function active_players()
 local active=0
 for pl in all(players) do
  if (pl.hp>0) active+=1
 end
 return active
end

function players_startx()
 for p in all(players) do
  p.x,p.y=56,160
 end
 if active_players()==2 then
  players[1].x,
  players[2].x=
   24,
   88
 end
end

function create_player(player)
 local x,col_lt,col_dk,hud_x,explosion_style,debris_style,sfx_shoot,rocket_sprites=
  56,11,3,1,6,debris_green,2,split"194,193,192,193"
 if player==2 then
  x,col_lt,col_dk,hud_x,explosion_style,debris_style,sfx_shoot,rocket_sprites=
   56,8,2,96,5,debis_red,3,split"226,225,224,225"
 end
 add(players,create_actor(x,y))

 local pl=players[#players]
  pl.num,
  pl.col_lt,
  pl.col_dk,
  pl.speed,
  pl.hud_x,
  pl.debris_style,
  pl.explosion_size,
  pl.explosion_style,
  pl.sfx_shoot,
  pl.score,
  pl.prev_dir,
  pl.generator,
  pl.shields,
  pl.lock_to_screen,
  pl.controls_enabled,
  pl.shot_enabled,
  pl.shot_cooldown,
  pl.shot_cooldown_timer,
  pl.rocket_sprites,
  pl.flash_hp,
  pl.flash_dynamo=
   player,
   col_lt,
   col_dk,
   1.35,
   hud_x,
   debris_style,
   3,
   explosion_style,
   sfx_shoot,
   0,                //score
   -1,               //pre_dir
   0,                //generator
   0,                //shields
   false,            //lock to screen
   true,             //controls enabled
   true,             //shot_eanbled
   5,                //shot_cooldown
   0,                //shot_cooldown_timer
   rocket_sprites,
   0,
   0

 pl.sprite=sprite_create({0,2,4,6,8},2,2)
 pl.sprite.frame=3.5
 sprite_hitbox(pl.sprite,4,3,7,9)
 //pl.sprite.show_hitbox=true
 pl.jet=sprite_create({40,41,56},1,1)
 // recolor the sprite using palette swap
 add(pl.sprite.pal_swaps,{10,pl.col_lt})
 add(pl.sprite.pal_swaps,{9,pl.col_dk})
 add(pl.jet.pal_swaps,{10,pl.col_lt})
end

function apply_player_damage(pl,damage,shake,force)
 shake = shake or false
 if pl.shields<=0 or force then
  if (shake) then
   screen_flash+=3
   screen_shake+=16
  end
  // did we just cross 50% mark
  // drop the power ups by 1 level
  if pl.hp>=50 and pl.hp-damage<50 then
   if (pl.shot_pattern>1) pl.shot_pattern-=1
  end
  pl.hp-=damage
  pl.shields+=180
  sfx(10)

  // transfer generator power
  // to hp
  if pl.hp<=0 and pl.generator>0 then
   pl.hp,
   pl.generator=
    pl.generator,
    0
  end

  if (pl.hp<=0) emit_explosion(pl.x,pl.y,pl.explosion_size,pl.explosion_style)
 end
end

function emit_smartbomb(pl)
 local max_exp=0
 for al in all(aliens) do
  if (pl) score_update(pl,al.reward*max_exp)
  if (max_exp<=6) emit_explosion(al.sprite.emit_x,al.sprite.emit_y,al.explosion_size,al.debris_size,debris_fire)
  screen_shake+=al.explosion_size
  max_exp+=1  
 end
 aliens,bullets={},{}
 screen_flash+=3
 sfx(8)
end

function apply_generator_charge(pl,charge)
 local new_gen=pl.generator+charge
 if new_gen>98 and pl.hp>98 then
  pl.generator,pl.hp=100,100
  score_update(pl,25000)
 elseif new_gen>100 then
  // if generator reaches 100
  // boost hp by 50
  pl.generator=new_gen-100
  pl.hp=min(100,pl.hp+50)
 else
  pl.generator=new_gen
 end   
end

function check_player_collisions(pl)
 for pu in all(pickups) do
  if sprite_collision(pl.sprite,pu.sprite) then
   gamestate.player_pickups+=1
   score_update(pl,10000)
   local pu_sound=9

   //every power-up charges the generator
   local charge=15

   if pu.payload==96 then
    // alien weapons jammer   
    gamestate.aliens_jammed+=pickup_base
    bullets={}
   elseif pu.payload==97 then
    //smartbomb
    emit_smartbomb(pl)
   elseif pu.payload==98 then
    // battery
    charge*=2
    pl.flash_dynamo+=300
    pu_sound=15
   elseif pu.payload==112 then
    //weapons
    pl.shot_pattern=min(4,pl.shot_pattern+1)
   elseif pu.payload==113 then
    //shields
    pl.shields+=pickup_base
   elseif pu.payload==114 then
    //hp
    local new_hp=pl.hp+15
    if new_hp>100 then
     pl.generator+=new_hp-100
     pl.hp=100
    else
     pl.hp=new_hp
    end
    pl.flash_hp+=300
    pu_sound=14
   end
   
   sfx(pu_sound)
		 apply_generator_charge(pl,charge)
		    
   del(pickups,pu)
  end
 end

 for al in all(aliens) do
  if sprite_collision(pl.sprite,al.sprite) then
   // destroy the alien
   gamestate.aliens_destroyed+=1
   score_update(pl,al.reward)
   emit_explosion(al.x+8,al.y,al.explosion_size)
   sfx(5+al.explosion_size)
   // damage the player
   apply_player_damage(pl,al.collision_damage,true)
   del(aliens,al)
  end
 end

 for bl in all(bullets) do
  if sprite_collision(pl.sprite,bl.sprite) then
   del(bullets,bl)
   sound_play(5)
   // damage the player
   apply_player_damage(pl,bl.damage)
  end
 end
end

function init_players()
 players,flashes,rockets={},{},{}
 for i=1,num_players do
  create_player(i)
 end 
 players_startx()
end

function update_players()
 stars_accx=0
 stars_accy*=.999

 for pl in all(players) do
  if (pl.hp<=0) goto next_player
  local controller=pl.num-1
  local dx,dy,dir=
   get_x_axis(controller),
   get_y_axis(controller),
   get_direction(controller)

   if pl.controls_enabled then
    // if moving diagonally
    if abs(dx)+abs(dy)==2 then
     // normalize movement vector
     // 1.41 is the sqrt(2)
     dx/=1.41
     dy/=1.41
     // prevent staircasing
     // clamp to whole pixel x,y
     // reference as origin
     if dir!=pl.prev_dir then
      pl.x,pl.y=flr(pl.x),flr(pl.y)
     end
    end
    pl.prev_dir=dir

    // integrate starfield accel
    apply_stars_accel(dx,dy)

    // finally, apply the input direction to the player
    pl.vel_x,pl.vel_y=
     dx*(pl.speed),
     dy*(pl.speed)
    pl.x+=pl.vel_x
    pl.y+=pl.vel_y
    
	  //fire rockets
	  if btn(4,controller) or btn(5,controller) then
	   if pl.shot_cooldown_timer<=0 and pl.shot_enabled then
	    pl.shot_cooldown_timer=pl.shot_cooldown
	    emit_rocket(pl.num)
	   elseif not pl.shot_enabled then
	    sound_play(13)
	   end
	  end    
  end

  // animate banking
  local spr_frame=pl.sprite.frame
  if dx==0 then
   if (spr_frame<3.5) spr_frame+=0.2
   if (spr_frame>3.5) spr_frame-=0.2
  elseif pl.controls_enabled then
   spr_frame+=dx*0.2
  end
  pl.sprite.frame=mid(1.1,spr_frame,5.9)
  // animate jets
  sprite_loop_frame(pl.jet,0.3)

  if pl.lock_to_screen then
   pl.x,pl.y=
    mid(-4,pl.x,116),
    mid(0,pl.y,112)
  end

  pl.shields=mid(0,pl.shields-1,pl.shields)

  pl.shot_damage=11-pl.shot_pattern

  pl.shot_cooldown=2.75+pl.shot_pattern*0.325
  pl.shot_cooldown_timer=max(pl.shot_cooldown_timer-0.75,0)
  if (#rockets<pl.shot_pattern*5) pl.shot_cooldown_timer*=0.25

  pl.flash_hp=max(0,pl.flash_hp-1)
  pl.flash_dynamo=max(0,pl.flash_dynamo-1)
  
  check_player_collisions(pl)

  ::next_player::
 end
end

function draw_players()
 draw_muzzle_flashes()
 for pl in all(players) do
  if (pl.hp<=0) goto dead
  sprite_draw(pl.sprite,pl.x,pl.y)
  sprite_draw(pl.jet,pl.x+3,pl.y+15)
  sprite_draw(pl.jet,pl.x+6,pl.y+15)
  if pl.shields>0 then
   x_center,y_center=
    pl.x+8,pl.y+10
   //ship has shields up
   if fc%6<3 then
    circ(x_center,y_center,14,pl.col_lt)
   elseif pl.shields%2 then
    local col=pl.col_dk
    if (pl.shields<=60) col=5
    fillp(░)
    circfill(x_center,y_center,14,col)
    fillp()
   end
  end
  ::dead::
 end
end

function emit_muzzle_flash(player_num)
 if #flashes<3 then
  add(flashes,{
   player=player_num,
   sprite=sprite_create(split"32,34,36,38",2,2)
  })
  sound_play(players[player_num].sfx_shoot)
 end
end

function draw_muzzle_flashes()
 for fl in all(flashes) do
  local pl=players[fl.player]
  sprite_loop_frame(fl.sprite,0.45)
  if fl.sprite.frame>#fl.sprite.frames then
   del(flashes,fl)
  else
   sprite_draw(fl.sprite,pl.x-4,pl.y-6)
   sprite_draw(fl.sprite,pl.x+4,pl.y-6)
  end
 end
end

-->8
--aliens

function emit_bullet(al)
 al.shot_cooldown_timer=al.shot_cooldown
 al.sprite.pal_whiteflash=1
 local bullet=create_projectile(al,al.x+al.x_off,al.y-al.y_off)
 bullet.sprite=sprite_create({al.shot_sprite},1,1)
 local size=3 
 if (al.shot_sprite==65) size=2
 if (al.shot_sprite==80) size=1
 sprite_hitbox(bullet.sprite,1,1,size,size)
 sfx(4)
 add(bullets,bullet)
 return bullet
end

function update_bullets()
 for bullet in all(bullets) do
  bullet.x+=bullet.speed_x
  bullet.y+=bullet.speed_y
  if is_outside_playarea(bullet.x,bullet.y) then
   del(bullets,bullet)
  end
 end
end

function create_alien(x,y,breed)
 //do not spawn over existing aliens
 if breed!="asteroid" then
  for check in all(aliens) do
   if ((x>=check.x-12 and x<=check.x+12) and (y>=check.y-12 and y<=check.y+12)) return
  end
 end

 local al=create_actor(x,y)
 al.breed,
 al.collision_damage,
 al.shot_cooldown,
 al.shot_cooldown_timer,
 al.x_off,
 al.y_off,
 al.framerate=
  breed,
  20,
  180,
  0,
  2,
  -6,
  0

 if breed=="drone" then
  al.hp,
  al.framerate,
  al.wave_speed,
  al.wave_width,
  al.shot_speed_x,
  al.shot_speed_y,
  al.shot_sprite=
   30,
   0.1,
   0.010,
   0.90,
   rnd_range(-0.25,0.25,true),
   1.25,
   80
  al.sprite=sprite_create(split"107,108,109,123,124,125",1,1)
  sprite_hitbox(al.sprite,1,1,5,5)
  al.sprite.frame=rnd_range(1,#al.sprite.frames)
 elseif breed=="asteroid" then
  // brown asteroid
  al.hp,
  al.framerate,
  al.speed_x,
  al.speed_y=
   40,
   0.055,
   rnd_range(-0.55,0.55,true),
   rnd_range(0.85,0.95,true)
  local rocks=split"87,88,89,90"
  if one_in(3) then
   // grey asteroid
   al.hp,
   al.framerate,
   al.collision_damage,
   al.speed_x,
   al.speed_y=
    60,
    0.085,
    30,
    rnd_range(-0.25,0.25,true),
    rnd_range(0.5,0.65,true)

   rocks=split"71,72,73,74"
  end
  al.sprite=sprite_create(rocks,1,1)
  sprite_hitbox(al.sprite,2,1,3,4)
  al.sprite.frame=rnd_range(1,#rocks)
 elseif breed=="orby" then
  al.hp,
  al.framerate,
  al.speed_x,
  al.speed_y,
  al.shot_sprite=
   50,
   0.075,
   0,
   0.5,
   80
  al.sprite=sprite_create(split"91,75,76,77,93,77,76,75",1,1)
  sprite_hitbox(al.sprite,1,1,5,5)
  al.sprite.frame=rnd_range(1,#al.sprite.frames)
 elseif breed=="bronze" then
  al.x=rnd_range(43,83)
  local angle=atan2(rnd_range(8,24)+al.x_off-al.x,127-al.y+al.y_off)
  if (x>63) angle=atan2(rnd_range(104,120)+al.x_off-al.x,127-al.y+al.y_off)
  al.hp,
  al.framerate,
  al.speed_x,
  al.speed_y,
  al.shot_speed_x,
  al.shot_speed_y,
  al.shot_sprite,
  al.explosion_size=
   60,
   0.1,
   cos(angle)*1.1,
   sin(angle)*1.1,
   1.5,
   1.5,
   65,
   rnd_range(1,2)
  al.sprite=sprite_create(split"68,69,70,69",1,1)
  sprite_hitbox(al.sprite,1,1,5,5)
 elseif breed=="silver" then
  al.x=rnd_range(24,104)
  local angle=atan2(rnd_range(al.x-20,al.x+20)+al.x_off-al.x,127-al.y+al.y_off)
  al.hp,
  al.framerate,
  al.speed_x,
  al.speed_y,
  al.shot_speed_x,
  al.shot_speed_y,
  al.shot_sprite,
  al.explosion_size=
   70,
   0.2,
   cos(angle)*1.75,
   sin(angle)*1.25,
   1.75,
   1.75,
   80,
   2
  al.sprite=sprite_create(split"103,104,105,106,119,120,121,122",1,1)
  sprite_hitbox(al.sprite,1,1,5,5)
  al.sprite.frame=rnd_range(1,#al.sprite.frames)
 elseif breed=="sapphire" then
  local target_x=rnd_range(48,127)
  al.x=rnd_range(0,31)
  if fc%2==0 then
   al.x=rnd_range(95,127)
   target_x=rnd_range(0,47)   
  end
  local angle=atan2(target_x-al.x+al.x_off,127-al.y+al.y_off)
  al.hp,
  al.speed_x,
  al.speed_y,
  al.shot_speed_x,
  al.shot_speed_y,
  al.shot_sprite,
  al.explosion_size=
   75,
   cos(angle)*1.45,
   sin(angle)*1.45,
   1.75,
   1.75,
   80,
   rnd_range(2,3)
  al.sprite=sprite_create({101},1,1)
  sprite_hitbox(al.sprite,1,1,5,5)
 elseif breed=="emerald" then
  al.hp,
  al.wave_speed,
  al.wave_width,
  al.shot_sprite,
  al.explosion_size=
   80,
   0.007,
   1.5,
   65,
   3
  al.sprite=sprite_create({117},1,1)
  sprite_hitbox(al.sprite,1,1,5,5)
 end
 al.debris_size=al.explosion_size
 al.reward=(al.hp+al.collision_damage*100)+al.explosion_size
 
 add(aliens,al)
 return al 
end

function aim_shot(bl,pl,al,predict)
 local vel_x,vel_y=0,0
 if predict then
  vel_x,vel_y=pl.vel_x,pl.vel_y
 end

 local angle=atan2(pl.x+8+vel_x-al.x+al.x_off,pl.y+8+vel_y-al.y+al.y_off)
 bl.speed_x=cos(angle)*al.shot_speed_x
 bl.speed_y=sin(angle)*al.shot_speed_y
end

function make_firing_decision(al)
 if (al.breed=="asteroid" or gamestate.aliens_jammed>0) return

 if al.shot_cooldown_timer<=0 then
  if al.breed=="drone" then
   for pl in all(players) do
    if pl.y>al.y and
       pl.x>=al.x and
       pl.x<=al.x+7 and
       one_in(15) then
     emit_bullet(al)
    end
   end
  elseif al.breed=="orby" and one_in(400) then
   for i=0,7 do
    local ang=0.375+((0.125+fc)*i)
    al.shot_speed_x,
    al.shot_speed_y=
     cos(ang),
     sin(ang)*1.2
    emit_bullet(al)
   end
  elseif al.breed=="bronze" and one_in(250) then
   bullet=emit_bullet(al)
   local x_target=rnd_range(88,112)
   if (al.x>=64) x_target=rnd_range(16,40)

   local angle=atan2(x_target-al.x+al.x_off,128-al.y+al.y_off)
   bullet.speed_x,bullet.speed_y=
    cos(angle)*al.shot_speed_x,
    sin(angle)*al.shot_speed_y
  elseif al.breed=="silver" and one_in(300) then
   //aimed shots
   for pl in all(players) do
    bullet=emit_bullet(al)
    aim_shot(bullet,pl,al)
   end
  elseif al.breed=="sapphire" and one_in(300) then
   //aimed shots, with estimated predictive compensation
   for pl in all(players) do
    bullet=emit_bullet(al)
    aim_shot(bullet,pl,al,true)
   end
  elseif al.breed=="emerald" and one_in(500) then
   for i=0,3 do
    local ang=0.695+((0.04+fc)*i)
    al.shot_speed_x,al.shot_speed_y=
     cos(ang)*1.5,
     sin(ang)*1.5
    emit_bullet(al)
   end
  end
 end
 al.shot_cooldown_timer=max(0,al.shot_cooldown_timer-1)
end

function update_aliens()
 for al in all(aliens) do
  make_firing_decision(al)

  al.sprite.pal_ghostly=false
  if gamestate.aliens_jammed>0 and al.breed!="asteroid" then
   al.sprite.pal_ghostly=true
  end
  
  if al.breed=="drone" or al.breed=="emerald" then
   local cos_wave=cos(al.speed_x)*al.wave_width
   al.x+=cos_wave
   al.y+=al.speed_y
   al.speed_x+=al.wave_speed
   if al.breed=="emerald" then
    local emerald_spr=117
    if (cos_wave<0.1) emerald_spr=116
    if (cos_wave>0.9) emerald_spr=118
    al.sprite.frames={emerald_spr}
   end
  else
   al.x+=al.speed_x
   al.y+=al.speed_y
  end

  sprite_loop_frame(al.sprite,al.framerate)

  if is_outside_playarea(al.x,al.y) then
   gamestate.aliens_escaped+=1
   del(aliens,al)
  end
 end
end

-->8
-- helpers

function unpack_split(...)
 return unpack(split(...))
end

function reset_pickup_timer()
 local low=rnd_range(pickup_base,pickup_base*1.5)
 pickup_timer=rnd_range(low,low*1.5)
end

function create_pickup(x,y,force)
 if pickup_timer<=0 or force then
  local payload=rnd_range(1,#pickup_payloads)
  // do not reset the pickup
  // timer if a drop was forced
  if (not force) reset_pickup_timer()
  add(pickups,{
   x=x,
   y=y,
   origin_x=x,
   origin_y=y,
   angle=rnd_range(0,359),
   payload=pickup_payloads[payload]
  })
  local pu=pickups[#pickups]
  pu.sprite=sprite_create({pu.payload},1,1)
  add(pu.sprite.pal_swaps,{6,-1})
  add(pu.sprite.pal_swaps,{13,-1})
  sprite_hitbox(pu.sprite,1,1,5,5)
 end
end

function update_pickups()
 for pu in all(pickups) do
  pu.angle+=2.5
  if (pu.angle>360) pu.angle=0
  pu.origin_y+=0.25+hyperspeed/4
  // 8 is the radius
  pu.x,pu.y=
   pu.origin_x+8*cos(pu.angle/360),
   pu.origin_y+8*sin(pu.angle/360)

  if (pu.origin_y<-12) del(pickups,pu)
 end
 pickup_timer=max(0,pickup_timer-1)
end

function create_projectile(actor,x,y)
 return {
  x=x,
  y=y,
  damage=actor.shot_damage,
  speed_x=actor.shot_speed_x,
  speed_y=actor.shot_speed_y
 }
end

function create_actor(x,y)
 return {
  x=x,
  y=y,
  speed_x=0,
  speed_y=0.5,
  debris_size=1,
  debris_style=nil,
  explosion_size=1,
  explosion_style=nil,
  shot_pattern=1,
  shot_damage=10,
  shot_speed_x=0,
  shot_speed_y=-4,
  hp=100
 }
end

// hitboxes have to be
// created using this function!
function sprite_hitbox(s,hbx,hby,hbw,hbh,show)
 s.hb_x,
 s.hb_y,
 s.hb_width,
 s.hb_height,
 s.hb_hw,
 s.hb_hh,
 s.show_hitbox=
  hbx,
  hby,
  hbw,
  hbh,
  hbw/2,
  hbh/2,  
  show
end

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
  emit_x=63,
  emit_y=-64,
  frame=1,
  pal_swaps={},
  pal_trans=0,
  pal_whiteflash=0,
  pal_ghostly=false,
  //show_hitbox=false
 }
end

function sprite_draw(s,x,y)
 // update x,y for collision detection
 s.x,s.y=x,y

 // calc where damage/bullet
 // emits from
 s.emit_x,
 s.emit_y=
  s.x+s.hb_hw,
  s.y+s.hb_hh

 // do palette swaps
 if (s.pal_trans>0) palt(s.pal_trans)

 // make sprite ghostly
 if s.pal_ghostly then
  pal(split"5,5,5,5,13,6,7,6,6,7,7,7,6,6,7")
 elseif s.pal_whiteflash>0 then
  s.pal_whiteflash-=1
  pal(split"13,13,13,13,13,7,7,7,6,7,7,7,6,6,7")
 else
  // color replacements
  for pal_swap in all(s.pal_swaps) do
   local alt=pal_swap[2]
   if (alt==-1) alt=sparkle
   pal(pal_swap[1],alt)
  end
 end

 spr(s.frames[flr(s.frame)],x,y,s.w,s.h,s.flip_x,s.flip_y)

 // reset palette
 if (#s.pal_swaps or s.pal_trans!=0 or s.pal_whiteflash or s.pal_ghostly) pal()
end

function sprite_loop_frame(s,val)
 s.frame+=val
 if (flr(s.frame)>#s.frames) s.frame=1
end

function sprite_collision(a,b)
 //ignore aliens spawning at the
 //top of the screen
 if (b.y<4) return

 local xd=abs((a.x+a.hb_x+a.hb_hw)-(b.x+b.hb_x+b.hb_hw))
 local xs=a.hb_hw+b.hb_hw
 local yd=abs((a.y+a.hb_y+a.hb_hh)-(b.y+b.hb_y+b.hb_hh))
 local ys=a.hb_hh+b.hb_hh

 return (xd<xs and yd<ys)
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

//function sound_channel_available(ch1,ch2,ch3,ch4)
function sound_channel_available(channels)
 //if music is playing check
 //channels 3 and 4
 local ch_start=1
 if (music_enabled>0) ch_start=3
 for ch=ch_start,4 do
  if (stat(channels[ch])==-1) return true
 end
 return false
end

// only plays sfx if a channel
// is available.
function sound_play(sound)
 //pico-8 >= 0.2.4
 local channels=split"46,47,48,49"

 // use deprecated audio sys
 // calls on pico-8 < 0.2.4
 if (stat(5)<36) channels=split"16,17,18,19"

 if sound_channel_available(channels) then
  sfx(sound)
 end
end

// pass in the player object
function score_update(pl,reward)
 pl.score+=reward >> 16
 if pl.score>hi_score then
  hi_score,hi_player=
   pl.score,pl.num
  dset(0,hi_score)
 end
end

function score_update_all(val)
 for pl in all(players) do
  if (pl.hp>0) score_update(pl,val)
 end
end

function round(n)
 return (n%1<0.5) and flr(n) or ceil(n)
end

function rnd_range(low,high,float)
 if (float) return rnd(high-low)+low
 return flr(rnd(high+1-low)+low)
end

function one_in(num)
 return rnd_range(1,num)==1
end

function is_outside_playarea(x,y)
 return (((x<-16 or y<-16) or (x>144 or y>144)))
end

function hud_line(x,y,x_width,val,col_lt,col_dk)
 line(x,y,x+x_width,y,col_dk)
 if val>0 then
  line(x,y,x+round(x_width/100*(val/100*100)),y,col_lt)
 end
end

function draw_hud()
 for pl in all(players) do
  local col_hp,col_dynamo=
   pl.col_lt,12

  // hud; score
  print_fx(numtostr(pl.score,8),pl.hud_x,0,pl.col_lt)

  // hud; hp & generator
  if (pl.flash_hp>0) col_hp=sparkle
  hud_line(pl.hud_x,6,30,pl.hp,col_hp,pl.col_dk)

  if (pl.flash_dynamo>0) col_dynamo=sparkle
  hud_line(pl.hud_x,7,30,pl.generator,col_dynamo,1)
 end
 
 print_fx("hi "..numtostr(hi_score,8),_center("hi 00000000",4),0,7)

 //mini-game hud
 if gamestate.hud_target then
  hud_line(42,6,42,gamestate.hud_progress/gamestate.hud_target*100,10,9)
 end 
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

function get_direction(controller)
 local mask=0xf
 if (controller==1) mask=0xf00
 return btn() & mask
end
__gfx__
00000001100000000000000110000000000000011000000000000001100000000000000110000000000990000009900000099000000000555500000008808800
00000016710000000000001671000000000000166100000000000016710000000000001671000000000990000009900000099000000015777651000087888880
000000111d100000000000111d1000000000011111100000000001d111000000000001d111000000009999000009900000977900000057ccc165000088888880
000001aaa1100000000001aaa1100000000001aaaa1000000000011aaa1000000000011aaa10000000999900009aa90000977900000056ccc165000008888820
00001a77aa11000000001a77aa11000000001a77aaa10000000011a77aa10000000011a77aa10000009aa90000977900097777900000561111d5000000888200
00001a7a9a11000000001a7a9a11000000001a7aa9a10000000011a7a9a10000000011a7a9a10000009aa9000097790009777790000015666d51000000082000
00001a999a11100000011a999a11100000111a9999a11100000111a999a11000000111a999a10000009aa90009a77a9097a77a79000001555510000000000000
00001a999a17100000011a999a17100000171a9999a17100000171a999a11000000171a999a100000097790009a77a9097a77a790000008ee800000000000000
00011aa97116100000161aa9971610000016117997116100000161799aa16100000161179aa110000097790009a77a909aa77aa9005dd526d25dd50000000000
0001d1a711d6d1000016d1a77116d10001d6d117711d6d10001d61177a1d6100001d6d117a1d1000009aa90009a77a909aa77aa905676d56d566665000000000
001ddd111d6d7d1001dddd1111dd6710176d6d1111d6d6710176dd1111dddd1001d7d6d111ddd100009aa900099aa9909a9aa9a9567666de8667766500000000
001dd6ddd6d66d1001dd66dddd6d66101666d6dddd6d66610166d6dddd66dd1001d66d6ddd6dd10000999900099aa990999aa999566666d82666766500000000
001d676676d6dd1001d6676676d6dd101dd6d676676d6dd101dd6d6766766d1001dd6d676676d1000099990009999990999aa999566666de8d66666500000000
000176d167d1110000117dd1171111000111171661711110001111711dd7110000111d761d67100000999900099999909099990905666d56d5d6665000000000
0000151155d110000001655155d11000000161511516100000011d551556100000011d5511510000000990000909909090099009005dd515515dd50000000000
0000011111110000000011111111000000001111111100000000111111110000000011111110000000099000000990000009900000055006d005500000000000
00000000000000000000000770000000000000000000000000000700000700000007000000070000000030000000200000000000005dd506d05dd50000000000
000000000000000000000007700000000000070000070000000000000000000000777000007770000100b000010080000000000005676d56d566665000000000
0000000000000000000000077000000000000700000700000000000000000000007a7000007a70000c00b0000c00800000000000567666d8e667766500000000
000000000000000000000007700000000000000000000000000000000000000000070000007a70000c00b0000c00800000000000566666d28666766500000000
000000000000000000007007700700000000000770000000000000000000000000000000000700000c00b0000c00800000000000566666d8ed66666500000000
000000000000000000077077770770000000000770000000700000000000000700070000000000000c000bb00c0008800000000005666d56d5d6665000000000
000000077000000000077077770770000700000770000070000000000000000000000000000700000c0000000c00000000000000005dd515515dd50000000000
000007777770000000007777777700000070007777000700000000000000000000000000000000000c0000000c0000000000000000055006d005500000000000
000077777777000000007777777700000000077777700000000000000000000000070000000000000d0000000d00000000000000005dd506d05dd50000000000
0000777777770000007077777777070000000777777000000000000000000000007770000009000000500000005000000000000005676d56d566665000000000
000777777777700000777777777777000070077777700700070000077000007000777000000a0000000dccc1000dccc100000000567666de8667766500000000
0007777777777000000777777777700000000777777000000000000770000000007a7000000a0000000000000000000000000000566666d82666766500000000
0000777777770000000077777777000000000777777000000000007777000000007a7000000a0000000000000000000000000000566666de8d66666500000000
0000077777700000000007777770000000000077770000000000007777000000000700000000aa0000000000000000000000000005666d5555d6665000000000
000000777700000000000077770000000000000770000000000000077000000000070000000000000000000000000000000000000055519aa915550000000000
0000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000fa700ff007af0000000000
19aa91001aaa10000001100000088000004040000040040000040400015551000015551001555100001555100067dd000067dd000067dd000000000000000000
9f77a900a77a9000001cc100008e78000f404f000f4004f000f404f015d66551155d66511566d55115566d51067dddd0067dddd0067dddd00000000000000000
a7777a00a7aa9000017ccc100d8e78d0046644f0ff4664ff0f446640566677655d6666d55d6666d556776665d6dddd5dd6dddd5dd6dddd5d000000cccc000000
a7777a00aaa9400001c7cc10d687e86d044444f0f444444f0f44444056666765566d66655666d66556766665d066550dd066550dd066550d00000c77ccc00000
9a77f90019940000001cc100d688886d048844904448844409448840566d666556666765567666655666d6656078000d6007800d6000780d0000c7c11ccc0000
19aa910000000000000110001d6666d1098e4900944e84490094e8905d6666d556667765567766655d6666d5d688005dd608805dd600885d0000c71111cc0000
00000000000000000000000001dddd10009196006941149600691900155d665115d6655115566d511566d5510266551002665510026655100000c181181c0000
000000000000000000000000000000000060060060900906006006000015551001555100001555100155510000221100002211000022110000ddc111111cdd00
17a1000015d6700000076d5100000000000000000000000000000000024442000024442002444200002444200067dd00000000000067dd000ddd5c1111c5ddd0
77aa0000556fa000000af6550000000000000000000000000000000024999442244999422499944224499942067dddd000000000067dddd0051dd555555dd150
aaa9000015d6700000076d51000000000000000000000000000000004999ff94499999944999999449ff9994d6dddd5d00000000d6dddd5d005dddddddddd500
1a90000000000000000000000000000000000000000000000000000049999f94499499944999499449f99994d766550d00000000d066558d0001555555551000
000000000000000000000000000000000000000000000000000000004994999449999f9449f99994499949946880000d000000006000078d0000600000060000
00000000000000000000000000000000000000000000000000000000499999944999ff9449ff999449999994d680005d00000000d600085d0006000000006000
00000000000000000000000000000000000000000000000000000000244999422499944224499942249994420266551000000000026655100000000000000000
00000000000000000000000000000000000000000000000000000000002444200244420000244420024442000022110000000000002211000000000000000000
01d66d1001d66d1001d66d10000000000011060006011060006011000600006006000600006000000060006001d66d1001d66d1001d66d100000016776100000
1500005115000051150000510000000000ccc10001cccc10001ccc00660dd066660dd6000660dd00006dd06615aaa95115aaa95115aaa9510001111111113000
d000000dd000800dd009900d000000000c99cc101cc99cc101cc99c067666676676667000670660000766676da77a99dda77a99dda77a99d0011113311113300
60929206608cc00660055006000000000c995cc0cc5995cc0cc599c0667777666677760006677700006dd7666a7aa9966a7aa9966a7aa996011131133111b510
60292906600cc80660055006000000000ca96cc0cc6a96cc0cc6a9c0067887600678860000677800006dd7606aa559966aaa55966aaaa5560113bb3111111310
d000000dd008000dd009900d000000000c606c000c6006c000c606c0067e8760067e860000677e00006dd760d990094dd999004dd999900d113bbb3111113bb3
1500005115000051150000510000000000c00c000c0000c000c00c0000677600006760000006700000067600159994511599945115999451113bb51111113bbb
01d66d1001d66d1001d66d100000000000c0c00000c00c00000c0c000006600000060000000060000000600001d66d1001d66d1001d66d101113b1111111133b
01d66d1001d66d1001d66d10000000003066300003066030000366030600006006000600000006000060006001d66d1001d66d1001d66d10111131bb31111113
1500005115000051150000510000000003dd3000003dd3000003dd30660dd066660dd60000dd0660006dd06615aaa95115aaa95115aaa951311113bbb3111113
d000a00dd00b300dd002200d0000000003aab30003baab30003baa3067766776676667000066076000766676da77a99dda77a99dda77a99d311113bbbb111133
6009a00660b0030660288206000000000b22a3003ba22ab3003a22b0677dd776667dd60000777660006777666a7aa9966a7aa9966a7aa996011113bbbb111130
600a900660300b0660888806000000000b223b00b032230b00b322b0067dd760067dd600008776000068876065aaa956655aa9966a55a9960111113bb1111110
d00a000dd003b00dd008800d00000000004230000034230000034200067dd760067dd60000e776000068e760d099940dd009994dd900994d0011113b11111100
1500005115000051150000510000000000b3b00000b33b00000b3b00006776000067600000076000000676001599945115999451159994510001113111111000
01d66d1001d66d1001d66d1000000000000b0000000bb0000000b0000006600000060000000600000000600001d66d1001d66d1001d66d100000011111100000
ccccccccccccc2ccccccccccccccccccccccccccccccc2ccccccccccccccccccccccccccccccc2cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccecccccc2ccccccccccccccccccccccccecccccccccccccccccccccccc2cccccceccccccccccccccccccccccccccccccc100001ccccccccccccc
cccc22cccccccfcccccc282ccccccccccc82cccccccccfccccccccc28ccccccccccc282ccccccfccccccc22ccccccccccccccccccccc00000000cccccccccccc
cccc22cc65cc2f2c760c282ccccccccccc82ccc765cc2f2cc567ccc28ccccccccccc282c76cc2f2cc76cc28cccccccccccccccccccc1000000001ccccccccccc
ccc822cc50cc2f2c650c2888ccccccccce82ccc550cc2f2cc055ccc28eccccccccc8882c50cc2f2cc55cc282ccccccccccccccccccc0000000000ccccccccccc
ccc882cc65cc8f8c760c888eccccccccce82ccc760cc8f8cc067ccc28eccccccccce888c76cc8f8cc76cc222ccccccccccccccccccc00700007001cccccccccc
ccce82cc65c02820650c888e8ccccccc8e82ccc650c02820c056ccc28e8ccccccc8e888c50cc2820c56cc288ccccccccccccccccccc07770077701cccccccccc
ccce82cc55c08e80550c888e8cccccccee82ccc550c08e80c055ccc28eeccccccc8e888c500c8e80c55cc288ccccccccccccccccccc07170071701cccccccccc
ccc822cc50c02820500c28ee8cccccccfe82ccc502c02820c205ccc28efccccccc8ee82c00002820c05cc288ccccccccccccccccccc071f0071f01cccccccccc
ccce822c00c02220508c28ee8cccccccfe882cc002c02220c200cc288efccccccc8ee82c80502220c00c2288ccccccccccccccccccc00f9999f001cccccccccc
ccce88202200282000e228fe8cccccccfe8828c2800028200082c8288efccccccc8ef822e05028200220222eccccccccccccccccccc09999999901cccccccccc
ccce88202005676508e28efe8ccccccc8f882822e005676500e228288f8ccccccc8efe82e80567650020228eccccccccccccccccccc00944429d01cccccccccc
ccce8220200055500ee28efecccccccccfe82822e000555000e22828efcccccccccefe82ee0055500020288ecccccccccccccccccc00069999d7005ccccccccc
cccfe822200000000ee28efecccccccccef828228000000000822828fecccccccccefe82ee0000000022288ecccccccccccccccccc0006667777001ccccccccc
cccce822000333330ee28efcccccccccccf82e280003333300082e28fcccccccccccfe82ee033333000228ecccccccccccccccccc000d6667777001ccccccccc
ccccee22003bbbbb3ee28eeccccccccccce82e88003bbbbb30088e28ecccccccccccee82ee3bbbbb300228eccccccccccccccccc1000666677777005cccccccc
ccccce82033bbabb3ef28eccccccccccccc82f82033bbabb33028f28ccccccccccccce82fe3bbabb330288cccccccccccccccccc000d666777777701cccccccc
cccccce203bba7ab3ee28ccccccccccccccc2ee203bba7abb302ee2ccccccccccccccc82fe3ba7abb302ecccccccccccccccccc100066677777777005ccccccc
cccccce203bba7ab38e28cccccccccccccccc2e203bba7abb302e2cccccccccccccccc82e83ba7abb302ecccccccccccccccccc000066677777777005ccccccc
ccccccc2033bbabb3382ccccccccccccccccccc2033bbabb3302ccccccccccccccccccc2833bbabb3302ccccccccccccccccccc000066777777777f01ccccccc
ccccccccc33bbbbb33ccccccccccccccccccccccc33bbbbb33ccccccccccccccccccccccc33bbbbb33cccccccccccccccccccc1000d6677777777f0005cccccc
cccccccccc3ba7ab3ccccccccccccccccccccccccc3ba7ab3ccccccccccccccccccccccccc3ba7ab3ccccccccccccccccccccc00006667777777f00001cccccc
ccccccccccc33333ccccccccccccccccccccccccccc33333ccccccccccccccccccccccccccc33333ccccccccccccccccccccc44440666777777f0004444ccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4999ad6677777700099994ccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc499999ad667777f009999994cccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4999999006677f0009999994cccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc49999999000677f00099999994ccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc49999999000d77f00099999944ccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4999999a0000000099999994cccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4499999011111109999944ccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44994cccccccc49944ccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc444cccccccc444ccccccccc
00033000000330000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000330000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300000330000037730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300003bb3000037730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003773000377773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003773000377773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb30003b77b3037b77b7300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0037730003b77b3037b77b7300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0037730003b77b303bb77bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb30003b77b303bb77bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300033bb3303b3bb3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300033bb330333bb33300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0033330003333330333bb33300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300033333303033330300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000030330303003300300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000330000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000880000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000880000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000880000087780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800008ee8000087780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008ee800008778000877778000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008ee800008778000877778000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008ee80008e77e8087e77e7800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0087780008e77e8087e77e7800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0087780008e77e808ee77ee800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008ee80008e77e808ee77ee800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008ee800088ee8808e8ee8e800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800088ee880888ee88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088880008888880888ee88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800088888808088880800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000080880808008800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000880000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000
00000000000000000000333333003333000033333300003333003300330000000000333333003300000033333300333333003333000000000000000000000000
00000000000000000003bbbbbb33bbbb3003bbbbbb3003bbbb33bb33bb3000000003bbbbbb33bb300003bbbbbb33bbbbbb33bbbb300000000000000000000000
00000000000000000003bbbbbb33bbbb3313bbbbbb3033bbbb33bb33bb3000000003bbbbbb33bb300003bbbbbb33bbbbbb33bbbb330000000000000000000000
00000000000000000003bb33bb33bb33bb3033bb3303bb333303bb33bb3000000003bb33bb33bb30000033bb3303bb333303bb33bb3000000000000000000000
00000000000000000003bb33bb33bb33bb3003bb3003bb333303bb33bb3000000013bb33bb33bb30000003bb3003bb330003bb33bb3000000000000000000000
00000000000000000003bbbbbb33bb33bb3003bb3003bbbbbb33bbbbbb3000000003bbbbbb33bb30000003bb3003bbbb3003bb33bb3000000000000000000000
00000000000000000003bbbbbb33bb33bb3003bb3003bbbbbb33bbbbbb3000000003bbbbbb33bb30000003bb3003bbbb3003bb33bb3000000000000000000000
00000000000000000003bb33bb33bb33bb3003bb30003333bb303333bb3000000003bb33bb33bb30000003bb3003bb330003bb33bb3000000000000000000000
00000000000000000003bb33bb33bb33bb3003bb30003333bb303333bb3000000003bb33bb33bb33330033bb3303bb333303bb33bb3000000000000000000000
00000000000000000003bb33bb33bb33bb3003bb3003bbbb3303bbbbbb3000000003bb33bb33bbbbbb33bbbbbb33bbbbbb33bb33bb3000000000000100000000
00000000000000000003bb33bb33bb33bb3003bb3003bbbb3003bbbbbb3000000003bb33bb33bbbbbb33bbbbbb33bbbbbb33bb33bb3000000000000000000000
00000000000000000000330033003300330000330000333300003333330000000000330033003333330033333300333333003300330000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000
00000000000000000000000000000000000022222200222222002222220022222200002222002200220000220000000000000000000000000000000000000000
00000000000000000000000000000000000288888822888888228888882288888820028888228822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288888822888888228888882288888820228888228822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288228820228822002288220288228822882222028822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228822882000028822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288888820028820000288200288888822882000028888220002882000000000000000000000000000000000000000
00000000000000000000000000000000000288888820028820000288200288888822882000028888220002882000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228822882000028822882000220000000000000000000000000000000000000000
00000000000010000000000000000000000288228820028820000288200288228822882222028822882000220000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228820228888228822882002882000000000000000000000000000000000000000
00000000000000000000000000000000000288228820028820000288200288228820028888228822882002882000000000000000000000000001000000000000
00000000000000000000000000000000000022002200002200000022000022002200002222002200220000220000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000077077700770077000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000707007007000707000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777007007000707000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000700077700770770000000000000000000000000000000000000000000000000000001000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000010000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000111110000000001110100011101110000011000000101011100000000111110000000000000000000000000001000000
00000000000000000000000000000001888881000000018881810188818181000188100001818188810000001888881000000000000000000000000000000000
00000000000000000000000000000018881188110000018181810181818181000018101111818181810000018811888100000001000000000000000000000000
00000000000000000000000000000018810188100000018881810188818881000018118881818188810000018810188100000000000000000000000000000000
00000000000000000000000000000018881188100000018111811181811181000018101111818181100000018811888100000000000000000000000000000000
00000000000000000000000000000001888881010000018101888181818881000188810000188181000000001888881000000000000000000000000000000000
00000000000000000000000000000000111110000000001000111010101110000011100000011010000000000111110000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000010000000000000000000000000001110101001101110011000000110111011100000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000001ccc1c1c11cc1ccc11cc100001cc1ccc1ccc10000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000001ccc1c1c1c1101c11c1100001c1c1c111c1100000000000000010000000000000000000000000000000
0000000000000000000000000000000000000000000001c1c1c1c1ccc11c11c1000001c1c1cc11cc100000000000000000000000000000000000000000000000
0000001000000000000000000000000000000000000001c1c1c1c111c11c11c1100001c1c1c101c1000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000001c1c11cc1cc11ccc11cc10001cc11c101c1000000000000000000000000000000000000000000000000
00000000000000001000000000000000000000000000001010011011001110011000001100100010000000000000000000000000000000000001000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000101011101000111000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001c1c1ccc1c101ccc100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001c1c1c111c101c1c100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001ccc1cc11c101ccc100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001000000001c1c1c111c111c11000000000000000100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001c1c1ccc1ccc1c10000000000000001000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000101011101110100000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000001000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000011011101110110011101110011000000000000000000000000000000000000000000000000000
000000000000000000000000000000001000000000000000001cc1ccc1ccc1cc11ccc1ccc11cc100000010000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000001c111c1c1c111c1c11c101c11c11000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000001c101cc11cc11c1c11c101c11ccc100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000001c111c1c1c111c1c11c101c1011c100000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000100000001cc1c1c1ccc1ccc1ccc11c11cc1000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000011010101110111011100100110000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000001000000000000000000
00000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000700100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777007770100000000000000000
00000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000100717007170100000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000071f0071f0100000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000ee0ee0000000000000000000000f9999f00100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000e88288200000000000000000000999999990100000000000000000
00000000000000000000000000000000007770077077007770000070707770777070700000e88888200000777007707700000094442900100000000000000000
00000000000000000000000000000000007770707070707700000070700700070070700000e88888200000770070707070000069999070050000000000000000
00000000000000000000000000000000007070777070707000000077700700070077700000028882000000700070707700000066677770010000000000000000
00000000000000000000000000000000007070707077000770000077707770070070700000002820000000700077007070000066677770010000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000001000666677777005000000000000000
00000000000000000000000000000000000070007770770070707070000007700770777077700000777007707770000000000666777777701000000000000000
00000000000000000000000000000000000070000700707070700700000070007070777077000000070070707770000010006667777777700500000000000000
00000000000000000000000000000000000070000700707070700700000070707770707070000000070077707070000000006667777777700500000000000000
000000000000000000000000000000000000077077707070077070700000777070707070077000007700707070700000000066777777777f0100000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100006677777777f00050000000000000
0000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000006667777777f000010000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440666777777f0004444000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004999a06677777700099994000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000499999a0667777f00999999400000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004999999006677f000999999400000000000
0000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000049999999000677f000999999940000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049999999000077f000999999440000000000
0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000004999999a000000009999999400000000000
00000000000000000500000005000000555055505550555000000000000000000000000000000000000000000000004499999011111109999944000000000000
00000000000000005750055057500005777577757775777500005050555055500550505005505050055055005000550044994550055054994400000000000000
00000000000000057500577505750000557575755575557500057575777577755775757557757575577577557505775000444775577574440000000000000000
00000000000000057505755005750005777575757775577500057575575577757575777575557575757575757505757500057555757577750000000000000000
10000000000010057505755005750005755575757550557500057775575575757775557555757775757577557555757505057555757575750000000000000000
00000000000000005750577557500005777577757775777500057775777575757555775577557775775575755775775057505775775575750010000000000000
00000000000000000500055005000000555055505550555000005550555050505000550055005550550050500550550005000550550050500000000000000000
00000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
000400002152526535005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000180251f535260452a55512604176011b6011f601226012560128601296012b601296012760124601216011f6011c601186011560113601116010f6010e60500500005000050000500005000050000500
340100001805014050100300e0300b030090300602002020000100500023700235000b20007200062000520003200022000120001200000000000000000000000000000000000000000000000000000000000000
7b0100001805014050100300e0300b030090300602002020000100500023700235000b20007200062000520003200022000120001200000000000000000000000000000000000000000000000000000000000000
46010000241201e1201911015110101200b1200911005110031200112000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000e63004620270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c475152740f474186651646515264114540e6550d4550b24408445066440443502234014340062500424002240041500615000040000400004000040000400004000040000400004000040000400004
000300000c363236650935520641063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
12030000256402c6602f6602f65027640206401a630136300e6500d650106401866022620106400b6300a65010630146101062001620006100061000000000000000000000000000000000000000000000000000
0007000023765287752d3021e105370021c0051330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021320207002070022b0001f0001f0021f0021f002
011000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000013150132501345000002660021600196001260011607116070c60710607156071a6071e607206072260722607206001d6001c60018600156001560014600166001a6001c6001c600166000f60000000
00020000187551a5551c7551554517745195451273514535167350f52511725135250c7150e515107150060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200000c05006731037150070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400000c5600f55114051180511b0411d0412000017000140000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00060000190611c0511f04122031280051f000220002200021000220001f0001f000220002200021000220001f0001f0002e0012e0002d0002e0002b0002b0002b0022b005000000000000000000000000000000
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
0114000020734200351c7341c0351973419535157343952520734200351c7341c0351953219035147341503121734210351c7341c0261973419035237341703521734395251c7341c03519734195351773717035
011400000c043090552072409055246151972315555090550c053090651972309565207242461509065155650c053060652072406065246151672306065125650c05306065167230656520724246150606515555
011400000c053021651e7240206524615197450e7650c05302165020651e7341e7350256524615020650e56501165010651e7240c05324615167230b0450d0650c05301165197440b56520724246150106515555
0114000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242a74228742287451c7341e7421e7421e735237241702521724395251c7341c03519734195351773617035
0014000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242f7422d7422d7452d734217422174221735237241702521724395251c7341c03519734195351773617035
__music__
00 11424344
01 11104344
00 11104344
00 11124344
00 13124344
02 13144344
01 15424344
00 18424344
00 19424344
00 15424344
00 15174344
00 18174344
00 19164344
02 151a4344
00 1f424344
01 1c1b4344
00 1c1b4344
02 1e1d4344
00 20214344
00 20224344
00 23214344
00 24224344
00 23214344
02 24224344

