pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- antsy alien attack pico
-- wimpysworld.com

// token anxiety
// 27/may: 2500

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
 screen_flash,screen_shake,sparkle=0,0,4

 //TODO: find a better way to
 //store this data
 debris_red="14,14,8,8,2,2"
 debris_green="10,11,11,11,3,3"
 debris_fire="10,9,9,8,8,2"

 dt,fc,tick,l_tick=0,0,0,0
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
 music_play(0)
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

function init_gameover()
 hyperspeed_target=0
 ignore_input=180
 music_play(0)
 update_loop,draw_loop=
  update_gameover,draw_gameover
end

function update_gameover()
 update_stars()
 if (any_action_btnp()) init_attract()
end

function draw_gameover()
 cls(0)
 draw_stars()
 print_bounce("game over",nil,48,8,nil,nil,32,8,"dotty")
 menu_footer()
end

function init_gamewin()
 ignore_input=180
 music_play(18)
 update_loop,draw_loop=
  update_gamewin,draw_gamewin
end

function update_gamewin()
 update_stars()
 if (any_action_btnp()) init_attract()
end

function draw_gamewin()
 cls(0)
 draw_stars()
 print_bounce("game win!",nil,48,11,nil,nil,32,8,"dotty")
 menu_footer()
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

 print_wave(help_text,nil,24,12,1,1,32,4)
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

function emit_debris(x,y,size,style)
 style = style or debris_fire
 col=split(style)[rnd_range(1,6)]

 for i=1,10 do
  add(debris,{
   x=x,
   y=y,
   sx=(rnd()-0.5)*6.5,
   sy=(rnd()-0.5)*2,
   col=col,
   decay=13
  })
	end
end

function update_debris()
 for d in all(debris) do
  d.sy-=0.2
  d.x+=d.sx
  d.y+=d.sy
  d.decay-=0.6
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
  //circ(sw.x,sw.y,sw.radius,sw.col)
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
 local wait=size+size*2+(3/size)
 local max_radius=size*3+(3/size)+size
 local spread=size*6+(4/size)
	local maxage=rnd(wait)+wait/2+size

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
			ex.y-=0.75

		 --max age
	 	if ex.age>=ex.maxage or ex.r<1 then
			 if ex.at_end=="collapse" then
				 ex.at_end=nil
				 ex.maxage+=300
				 ex.tor=0
				 ex.spd=0.2
				 ex.wait=0
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
			local layer={
		  0,
		  r*0.05,
			 r*0.17,
			 r*0.35,
			 r*0.60
			}
			local style={
			 "1,4,9,10,7",  --yellow
			 "5,4,9,10,15", --orange
			 "1,4,8,9,10",  --fire
		  "1,5,13,6,7",  --smoke
			 "1,2,8,14,7",  --red
			 "1,3,11,10,7", --green
			 "1,13,12,6,7"  --blue
			}

			for i=1,#layer do
			 circfill(
			  ex.x,
			  ex.y-layer[i],
			  ex.r-layer[i],
			  split(style[ex.style])[i]
			 )
			end
		end
	end
end
// cls with flash and shake
function cls_fx(col,flash)
 if screen_flash>0 then
  screen_flash=max(screen_flash,0)-1
  cls(flash)
 else
  cls(col)
 end
 local shakex,shakey=
  rnd(screen_shake)-(screen_shake/2),rnd(screen_shake)-(screen_shake/2)
 camera(shakex,shakey)
end

function update_screen_shake()
 if (screen_shake>10) screen_shake*=0.95 else screen_shake-=1
 screen_shake=max(screen_shake,0)
end

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
 local players=active_players()

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
 _txt_wide,_txt_high=8,10
 return "\^t\^w"..txt
end

function _solid(txt)
 return "^\#"..txt
end

function _invert(txt)
 return "\^i"..txt
end

function _dotty(txt)
 _txt_wide,_txt_high=8,10
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
 debris,
 shockwaves,
 explosions=
  {},{},{}

 music_play(6)
 init_players()
 update_loop,draw_loop=
  update_game,draw_game
end

function update_game()
 update_screen_shake()
 update_stars()
 update_players()
 update_shockwaves()
 update_debris()
 update_explosions()

 if active_players()<1 and #explosions<=0 then
  init_gameover()
 end
end

function draw_game()
 cls_fx(0,9)
 draw_stars()
 
 print_bounce("coming june 6th 2023!",nil,60,12,1,1,32,8) 
 
 draw_players()
 draw_shockwaves()
 draw_debris()
 draw_explosions()
 print_fx("hi "..numtostr(hi_score,7),_center("hi 0000000",4),0,7)
end

// recreated for each objective
// counters used to determine
// if game objectives have been
// completed
function create_gamestate()
 return {
  aliens_destroyed=0,
  aliens_escaped=0,
  aliens_hit=0,
  aliens_max=0,
  player_collisions=0,
  player_bombs=0,
  player_misses=0,
  player_pickups=0,
  player_shots=0,
  hud_progress=0,
  hud_target=nil,
  boss_hp=0,
  ally_hp=0,
  gametime=0,
  mission_report_time=0,
  ready=false,
  title="",
  text="",
  draw=nil,
 }
end
-->8
--players

function active_players()
 local active=0
 for pl in all(players) do
  if (pl.hp>0) active+=1
 end
 return active
end

function players_startx()
 if active_players()==2 then
  players[1].startx,players[2].startx=24,88
 else
  // works for 1-up or 2-up
  // even if 1-up dies
  for p in all(players) do
   p.startx=56
  end
 end
end

function create_player(player)
 local x,col_lt,col_dk,hud_x,explosion_style,debris_style,sfx_shoot=
  56,11,3,1,6,debris_green,2
 if player==2 then
  x,col_lt,col_dk,hud_x,explosion_style,debris_style,sfx_shoot=
   56,8,2,100,5,debis_red,3
 end
 add(players,create_actor(x,96))

 local pl=players[#players]
 pl.num=player
	pl.col_lt,pl.col_dk=col_lt,col_dk
	pl.speed=1.35
	pl.hud_x=hud_x
	pl.debris_style=debris_style
	pl.explosion_size=3
	pl.explosion_style=explosion_style
	pl.shot_speed=2.5
	pl.sfx_shoot=sfx_shoot
	pl.shields=100
	pl.prev_dir=-1

 pl.sprite=sprite_create({0,2,4,6,8},2,2)
 pl.sprite.frame=3.5
 sprite_hitbox(pl.sprite,4,3,7,9)
 pl.sprite.show_hitbox=true
 pl.jet=sprite_create({40,41,56},1,1)
 // recolor the sprite using palette swap
 add(pl.sprite.pal_swaps,{10,pl.col_lt})
 add(pl.sprite.pal_swaps,{9,pl.col_dk})
 add(pl.jet.pal_swaps,{10,pl.col_lt})
end

function init_players()
 players,flashes,rockets={},{},{}
 create_player(1)
 if (num_players==2) create_player(2)
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
  pl.x+=dx*pl.speed
  pl.y+=dy*pl.speed

  // animate banking
  local spr_frame=pl.sprite.frame
  if dx==0 then
   if (spr_frame<3.5) spr_frame+=0.2
   if (spr_frame>3.5) spr_frame-=0.2
  elseif pl.controls_enabled then
   spr_frame+=dx*0.2
  end
  pl.sprite.frame=mid(1.1,spr_frame,5.9)

  //fire lazer
  if btn(4,controller) then
   if pl.shot_cooldown_timer<=0 and pl.shot_enabled then
    pl.shot_cooldown_timer=pl.shot_cooldown
    emit_muzzle_flash(pl.num)
   end
  end

  pl.shot_cooldown_timer-=1
  pl.shot_cooldown_timer=max(pl.shot_cooldown_timer,0)


  // animate jets
  sprite_loop_frame(pl.jet,0.3)

  ::next_player::
 end
end

function draw_players()
 draw_muzzle_flashes()
 for pl in all(players) do
  sprite_draw(pl.sprite,pl.x,pl.y)
  sprite_draw(pl.jet,pl.x+3,pl.y+15)
  sprite_draw(pl.jet,pl.x+6,pl.y+15)
 end
end

function emit_muzzle_flash(player_num)
 if #flashes<active_players() then
  add(flashes,{
   player=player_num,
   sprite=sprite_create({32,34,36,38},2,2)
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
-- tab 5
-->8
-- helpers

function create_projectile(actor,x,y)
 return {
  x=x,
  y=y,
  damage=actor.shot_damage,
  speed=actor.shot_speed,
  pattern=actor.shot_pattern
 }
end

// generic properties for
// players and npcs
function create_actor(x,y)
 return {
  x=x,
  y=y,
  breed=nil,
  speed_x=0,
  speed_y=0.5,
  score=0,
  reward=123,
  bomb_enabled=true,
  debris_size=1,
  debris_style=nil,
  explosion_size=1,
  explosion_quantity=1,
  explosion_screen_flash=0,
  explosion_screen_shake=0,
  explosion_style=nil,
  sfx_birth=nil,
  sfx_death=nil,
  sfx_shoot=nil,
  shot_enabled=true,
  shot_cooldown=4,
  shot_cooldown_timer=0,
  shot_pattern="",
  shot_damage=10,
  shot_speed=0.2,
  collision_damage=20,
  col_lt=10,
  col_dk=9,
  sprite={},
  jet={},
  hp=100,
  generator=0,
  shields=0,
  lock_to_screen=false,
  controls_enabled=true,
 }
end
// hitboxes have to be
// created using this function!
function sprite_hitbox(s,hbx,hby,hbw,hbh,show)
 s.hb_x,s.hb_y,s.hb_width,s.hb_height=
  hbx,hby,hbw,hbh
 s.show_hitbox=show

 // calculate half widths/heights
 // used for collision detection
 s.hb_hw=s.hb_width/2
 s.hb_hh=s.hb_height/2
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

function sprite_loop_frame(s,val)
  s.frame+=val
  if (flr(s.frame)>#s.frames) s.frame=1
end

// http://gamedev.docrobs.co.uk/first-steps-in-pico-8-hitting-things
function sprite_collision(a,b)
 local xd=abs((a.x+a.hb_x+a.hb_hw)-(b.x+b.hb_x+b.hb_hw))
 local xs=a.hb_hw+b.hb_hw
 local yd=abs((a.y+a.hb_y+a.hb_hh)-(b.y+b.hb_y+b.hb_hh))
 local ys=a.hb_hh+b.hb_hh

 if (xd<xs and yd<ys) return true
 return false
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

function sound_channel_available(ch1,ch2,ch3,ch4)
 //if music is playing only check
 //channels 3 and 4 which are
 //reserved for sfx by music_play()
 if music_enabled>0 then
  if stat(ch3)==-1 or stat(ch4)==-1 then
   return true
  end
 else
  if stat(ch1)==-1 or stat(ch2)==-1 or stat(ch3)==-1 or stat(ch4)==-1 then
   return true
  end 
 end
 return false
end

// only plays sfx if a channel
// is available. use for low
// priority sounds. essential
// sounds should be played with
// sfx() as it will drop currently
// playing sfx
function sound_play(sound)
 // use deprecated audio sys
 // calls on pico-8 < 0.2.4
 if stat(5) < 36 then
  if sound_channel_available(16,17,18,19) then
   sfx(sound)  
  end
 else
  //pico-8 >= 0.2.4
  if sound_channel_available(46,47,48,49) then
   sfx(sound)
  end
 end
end

function round(n)
 return (n%1<0.5) and flr(n) or ceil(n)
end

function rnd_range(low,high)
 return flr(rnd(high+1-low)+low)
end

function is_outside_playarea(x,y)
 return (((x<-32 or y<-32) or (x>144 or y>144)))
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
00000001100000000000000110000000000000011000000000000001100000000000000110000000000990000009900000099000000000555500000000000000
00000016710000000000001671000000000000166100000000000016710000000000001671000000000990000009900000099000000015777651000000000000
000000111d100000000000111d1000000000011111100000000001d111000000000001d111000000000990000009900000977900000057ccc165000000000000
000001aaa1100000000001aaa1100000000001aaaa1000000000011aaa1000000000011aaa10000000099000009aa90000977900000056ccc165000000000000
00001a77aa11000000001a77aa11000000001a77aaa10000000011a77aa10000000011a77aa100000009900000977900097777900000561111d5000000000000
00001a7a9a11000000001a7a9a11000000001a7aa9a10000000011a7a9a10000000011a7a9a10000000990000097790009777790000015666d51000000000000
00001a999a11100000011a999a11100000111a9999a11100000111a999a11000000111a999a10000009aa90009a77a9097a77a79000001555510000000000000
00001a999a17100000011a999a17100000171a9999a17100000171a999a11000000171a999a100000097790009a77a9097a77a790000008ee800000000000000
00011aa97116100000161aa9971610000016117997116100000161799aa16100000161179aa110000097790009a77a909aa77aa9005dd526d25dd50000000000
0001d1a711d6d1000016d1a77116d10001d6d117711d6d10001d61177a1d6100001d6d117a1d1000009aa90009a77a909aa77aa905676d56d566665000000000
001ddd111d6d7d1001dddd1111dd6710176d6d1111d6d6710176dd1111dddd1001d7d6d111ddd100009aa900099aa9909a9aa9a9567666de8667766500000000
001dd6ddd6d66d1001dd66dddd6d66101666d6dddd6d66610166d6dddd66dd1001d66d6ddd6dd100009aa900099aa990999aa999566666d82666766500000000
001d676676d6dd1001d6676676d6dd101dd6d676676d6dd101dd6d6766766d1001dd6d676676d1000099990009999990999aa999566666de8d66666500000000
000176d167d1110000117dd1171111000111171661711110001111711dd7110000111d761d67100000999900099999909099990905666d56d5d6665000000000
0000151155d110000001655155d11000000161511516100000011d551556100000011d5511510000000990000909909090099009005dd515515dd50000000000
0000011111110000000011111111000000001111111100000000111111110000000011111110000000099000000990000009900000055006d005500000000000
00000000000000000000000770000000000000000000000000000700000700000007000000070000005555000055550000000000005dd506d05dd50000000000
0000000000000000000000077000000000000700000700000000000000000000007770000077700015777651157776510000000005676d56d566665000000000
0000000000000000000000077000000000000700000700000000000000000000007a7000007a700057ccc15d57ccc16500000000567666d8e667766500000000
000000000000000000000007700000000000000000000000000000000000000000070000007a700056ccc156d6ccc16500000000566666d28666766500000000
00000000000000000000700770070000000000077000000000000000000000000000000000070000561111d6761111d500000000566666d8ed66666500000000
0000000000000000000770777707700000000007700000007000000000000007000700000000000015666d5115666d510000000005666d56d5d6665000000000
00000007700000000007707777077000070000077000007000000000000000000000000000070000015555100155551000000000005dd515515dd50000000000
000007777770000000007777777700000070007777000700000000000000000000000000000000000000e882288e00000000000000055006d005500000000000
00007777777700000000777777770000000007777770000000000000000000000007000019aa9100005dd526d25dd50000000000005dd506d05dd50000000000
0000777777770000007077777777070000000777777000000000000000000000007770009f77a90005676d56d56666500000000005676d56d566665000000000
000777777777700000777777777777000070077777700700070000077000007000777000a7777a00567666de8667766500000000567666de8667766500000000
0007777777777000000777777777700000000777777000000000000770000000007a7000a7777a00566666d82666766500000000566666d82666766500000000
0000777777770000000077777777000000000777777000000000007777000000007a70009a77f900566666de8d66666500000000566666de8d66666500000000
00000777777000000000077777700000000000777700000000000077770000000007000019aa910005666d56d5d666500000000005666d5555d6665000000000
00000077770000000000007777000000000000077000000000000007700000000007000000000000005dd515515dd500000000000055519aa915550000000000
0000000000000000000000000000000000000000000000000000000000000000000700000000000000055006d00550000000000000fa700ff007af0000000000
19aa910017a1000001d66d1001d6d100000000000000000001d66d10015551000015551001555100001555100000000000000000000000000000000000000000
9f77a90077aa000015aaa95115aaa510000000000000000015e88e5115d66551155d66511566d55115566d510000000000000000000000000000000000000000
a7777a00aaa90000da77a99dda77a9d00000000000000000de8228ed566677655d6666d55d6666d5567766650000000000000000000000000000000000000000
a7777a001a9000006a7aa9966a7aa9600000000000000000682f228656666765566d66655666d665567666650000000000000000000000000000000000000000
9a77f900000000006aaa9996daaa94d0000000000000000068222286566d666556666765567666655666d6650000000000000000000000000000000000000000
19aa910000000000d999994d159945100000000000000000de8228ed5d6666d556667765567766655d6666d50000000000000000000000000000000000000000
00000000000000001599945101d6d100000000000000000015e88e51155d665115d6655115566d511566d5510000000000000000000000000000000000000000
000000000000000001d66d1000000000000000000000000001d66d10001555100155510000155510015551000000000000000000000000000000000000000000
00000000000000001aaa100000999000000000000000000000000000024442000024442002444200002444200000000000000000000000000000000000000000
0000000000000000a77a900009fff900000000000000000000000000249994422449994224999442244999420000000000000000000000000000000000000000
0000000000000000a7aa90009f77ff900000000000000000000000004999ff94499999944999999449ff99940000000000000000000000000000000000000000
0000000000000000aaa940009f7fff9000000000000000000000000049999f94499499944999499449f999940000000000000000000000000000000000000000
0000000000000000199400009fffff900000000000000000000000004994999449999f9449f99994499949940000000000000000000000000000000000000000
00000000000000000000000009fff900000000000000000000000000499999944999ff9449ff9994499999940000000000000000000000000000000000000000
00000000000000000000000000999000000000000000000000000000244999422499944224499942249994420000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000002444200244420000244420024442000000000000000000000000000000000000000000
000000000000000001d66d1001d66d1001d66d100000016776100000001100000011000000110000001100000000000000000000000000000000000000000000
000000000000000015cccc5115cccc5115cccc5100011111111130000155100001cc100001881000012210000000000000000000000000000000000000000000
0000000000000000dcc67ccddccc6ccddcc77ccd00111133111133001d55510017ccc1001e888100182221000000000000000000000000000000000000000000
00000000000000006c677cc66c677cc66cc66cc6011131133111b51015d551001c7cc10018e88100128221000000000000000000000000000000000000000000
00000000000000006c7776c66cc776c66cc66cc60113bb31111113100155100001cc100001881000012210000000000000000000000000000000000000000000
0000000000000000dccc6ccddcc6cccddcc77ccd113bbb3111113bb3001100000011000000110000001100000000000000000000000000000000000000000000
000000000000000015cccc5115cccc5115cccc51113bb51111113bbb000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000001d66d1001d66d1001d66d101113b1111111133b000000000000000000000000000000000000000000000000000000000000000000000000
156000000000000001d66d1001d66d1001d66d10111131bb31111113001100000011000000110000001100000000000000000000000000000000000000000000
567000000000000015cccc5115cccc5115cccc51311113bbb31111130133100001bb100001ee1000016610000000000000000000000000000000000000000000
1560000000000000dcc76ccddcc76ccddcc66ccd311113bbbb1111331b3331001abbb10017eee100176661000000000000000000000000000000000000000000
00000000000000006c7776c66c7cc6c66c6776c6011113bbbb11113013b331001babb1001e7ee100167661000000000000000000000000000000000000000000
00000000000000006c6777c66c6cc7c66c7777c60111113bb11111100133100001bb100001ee1000016610000000000000000000000000000000000000000000
0000000000000000dcc67ccddcc67ccddcc77ccd0011113b11111100001100000011000000110000001100000000000000000000000000000000000000000000
000000000000000015cccc5115cccc5115cccc510001113111111000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000001d66d1001d66d1001d66d100000011111100000000000000000000000000000000000000000000000000000000000000000000000000000
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

__sfx__
000400002152526535005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000180251f535260452a55512604176011b6011f601226012560128601296012b601296012760124601216011f6011c601186011560113601116010f6010e60500500005000050000500005000050000500
1d0100001805014050100300e0300b030090300602002020000100500023700235000b20007200062000520003200022000120001200000000000000000000000000000000000000000000000000000000000000
7b0100001805014050100300e0300b030090300602002020000100500023700235000b20007200062000520003200022000120001200000000000000000000000000000000000000000000000000000000000000
47010000241501e1501914015140101500b1500914005140031500115000140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000e63004620270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c475152740f474186651646515264114540e6550d4550b24408445066440443502234014340062500424002240041500615000040000400004000040000400004000040000400004000040000400004
000300000c363236650935520641063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
12030000256402c6602f6602f65027640206401a630136300e6500d650106401866022620106400b6300a65010630146101062001620006100061000000000000000000000000000000000000000000000000000
0007000023745287452d3021e105370021c0051330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021320207002070022b0001f0001f0021f0021f002
011000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000013150132501345000002660021600196001260011607116070c60710607156071a6071e607206072260722607206001d6001c60018600156001560014600166001a6001c6001c600166000f60000000
00020000187551a5551c7551554517745195451273514535167350f52511725135250c7150e515107150060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200000c05006731037150070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100002705027040270300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002705027040270300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

