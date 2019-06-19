
Figs = {
	{
		{ 0, 0, 0, 0 },
		{ 0, 1, 1, 0 },
		{ 0, 1, 1, 0 },
		{ 0, 0, 0, 0 },
	},
	{
		{ 0, 1, 0, 0 },
		{ 0, 1, 0, 0 },
		{ 0, 1, 0, 0 },
		{ 0, 1, 0, 0 },
	},
	{
		{ 0, 0, 0, 0 },
		{ 0, 1, 0, 0 },
		{ 0, 1, 1, 0 },
		{ 0, 1, 0, 0 },
	},
	{
		{ 0, 0, 0, 0 },
		{ 0, 1, 0, 0 },
		{ 0, 1, 1, 0 },
		{ 0, 0, 1, 0 },
	},
	{
		{ 0, 0, 0, 0 },
		{ 0, 1, 1, 0 },
		{ 0, 0, 1, 0 },
		{ 0, 0, 1, 0 },
	},
	{
		{ 0, 0, 0, 0 },
		{ 0, 1, 1, 0 },
		{ 0, 1, 0, 0 },
		{ 0, 1, 0, 0 },
	},
}


function love.load()
    CellSize = { 20, 20 }
	CellCount = { 10, 20 }
	Mode = "load"
	GameTime = 0
	GameScore = 0
	LastGameTimeCnt = love.timer.getTime( )
	
	CellArr = {}
	for XX = 1, CellCount[ 1 ] do
		CellArr[ XX ] = {}
		for YY = 1, CellCount[ 2 ] do
			CellArr[ XX ][ YY ] = 0
		end
	end

	NextFig = nil
	NewFig = nil
	NewFigPos = { 0, 0 }
end
 

function FigCopy( Target, Src )
	for I = 1, 4 do
		Target[ I ] = {}
		for J = 1, 4 do
			Target[ I ][ J ] = Src[ I ][ J ]
		end
	end
 end


function CheckCollisionByPos( CellX, CellY, Figure )
	local function CheckBorderColl( X, Y )
		if X < 1 or X > CellCount[ 1 ] or Y < 1 or Y >= CellCount[ 2 ] then
			return true
		else
			return false
		end
	end	
	
	for IndY = 1, 4 do
		for IndX = 1, 4 do
			if Figure[ IndY ][ IndX ] == 1 then
				BlockPosX = IndX + CellX - 1
				BlockPosY = IndY + CellY - 1
				
				if CheckBorderColl( BlockPosX, BlockPosY ) then
					return true
				end
				if CellArr[ BlockPosX ][ BlockPosY ] == 1 or CellArr[ BlockPosX ][ BlockPosY + 1 ] == 1 then
					return true
				end
			end
		end
	end
	return false
end


function UpdateLogic()
	local IsCollision = CheckCollisionByPos( NewFigPos[ 1 ], NewFigPos[ 2 ], NewFig )
	
	if IsCollision and NewFigPos[ 2 ] < 3 then	
		Mode = "over"
	end

	if IsCollision then
		for IndY = 1, 4 do
			for IndX = 1, 4 do
				if NewFig[ IndY ][ IndX ] == 1 then
					BlockPosX = IndX + NewFigPos[ 1 ] - 1
					BlockPosY = IndY + NewFigPos[ 2 ] - 1
					CellArr[ BlockPosX ][ BlockPosY ] = 1			
				end
			end
		end	

		NewFig = nil
	end

	if IsCollision then
		for By = 1, CellCount[ 2 ] do
			local IsFull = true
			for Bx = 1, CellCount[ 1 ] do				
				if CellArr[ Bx ][ By ] == 0 then
					IsFull = false					
				end				
			end
			if IsFull then
				for I = 2 + CellCount[ 2 ] - By, CellCount[ 2 ] do
					local InvInd = CellCount[ 2 ] - I + 2
					for Bx = 1, CellCount[ 1 ] do
						CellArr[ Bx ][ InvInd ] = CellArr[ Bx ][ InvInd - 1 ]
					end			
				end
				GameScore = GameScore + 1
			end
		end
	end
end


function love.update(dt)
   if love.keyboard.isDown( "down" ) and Mode == "game" and NewFig then
		NewFigPos[ 2 ] = NewFigPos[ 2 ] + 1
		UpdateLogic()
   end
   
   if LastGameTimeCnt + 1 < love.timer.getTime() and Mode == "game" then
		LastGameTimeCnt = love.timer.getTime()
		GameTime = GameTime + 1

		if not NextFig then
			NextFig = {}
			FigCopy( NextFig, Figs[ love.math.random( 1, #Figs ) ] )							
		end
		if not NewFig then
			NewFig = {}
			FigCopy( NewFig, NextFig )	
			NextFig = nil
			NewFigPos = { 4, 1 }
		else
			NewFigPos[ 2 ] = NewFigPos[ 2 ] + 1
			UpdateLogic()
		end
   end
end
 

function love.keypressed( key, scancode, isrepeat )
	if key == 's' and Mode == "load" then
		Mode = "game"
	end
	if Mode == "game" and NewFig then
		if key == 'left' then
			if not CheckCollisionByPos( NewFigPos[ 1 ] - 1, NewFigPos[ 2 ], NewFig ) then
				NewFigPos[ 1 ] = NewFigPos[ 1 ] - 1
			end
		end
		if key == 'right' then
			if not CheckCollisionByPos( NewFigPos[ 1 ] + 1, NewFigPos[ 2 ], NewFig ) then
				NewFigPos[ 1 ] = NewFigPos[ 1 ] + 1
			end
		end
		if key == 'up' then
			local RotatedFig = {}
			for I = 1, 4 do
				RotatedFig[ I ] = {}
				for J = 1, 4 do
					RotatedFig[ I ][ J ] = NewFig[ J ][ 5 - I ]
				end
			end

			if not CheckCollisionByPos( NewFigPos[ 1 ], NewFigPos[ 2 ], RotatedFig ) then
				FigCopy( NewFig, RotatedFig )	
			end
		end
		if key == 'down' then

		end
	end	
end


function DrawBlock( X, Y )
	X = X * CellSize[ 1 ] + 20
	Y = Y * CellSize[ 2 ] + 20
	love.graphics.setColor(0, 100, 100)
	love.graphics.rectangle( "fill", X, Y, CellSize[ 1 ], CellSize[ 2 ] )
	love.graphics.setColor(222, 100, 100)
	love.graphics.rectangle( "fill", X + 2, Y + 2, CellSize[ 1 ] - 4, CellSize[ 2 ] - 4 )
end


function DrawFigure( X, Y, Figure )
	for I = 1, 4 do				
		for J = 1, 4 do				
			if Figure[ J ][ I ] == 1 then
				DrawBlock( I + X - 1, J + Y - 1 )
			end
		end
	end
end


function love.draw()
	if Mode == "load" then
		love.graphics.setColor( 220, 100, 100 )
		love.graphics.print( "__TETRIS__ by emptiness_rain for gd.ru" , 300, 200 )
		love.graphics.print( "press 's' to start or not" , 300, 220 )
	end
	if Mode == "over" then
		love.graphics.setColor( 220, 22, 22 )
		love.graphics.print( "GAME OVER" , 300, 200 )
		love.graphics.print( "Time:" .. GameTime , 300, 220 )
		love.graphics.print( "Score:" .. GameScore , 300, 240 )
	end
	if Mode == "game" then
		for By = 1, CellCount[ 2 ] do
			for Bx = 1, CellCount[ 1 ] do
				if CellArr[ Bx ][ By ] == 1 then
					DrawBlock( Bx, By )
				end
			end
		end

		if NextFig then	
			DrawFigure( 15, 5, NextFig )
		end

		if NewFig then	
			DrawFigure( NewFigPos[ 1 ], NewFigPos[ 2 ], NewFig )
		end

		love.graphics.setColor( 220, 222, 222 )		
		love.graphics.print( "Score:" .. GameScore , 300, 200 )
		love.graphics.print( "Time:" .. GameTime , 300, 220 )

		love.graphics.setColor(0, 100, 100)
		love.graphics.rectangle("line", 30, 30, CellSize[ 1 ] * CellCount[ 1 ] + 20, CellSize[ 2 ] * CellCount[ 2 ] + 20 )
	end
end


--mencoder mf://*.jpg -mf fps=25:type=jpeg -noskip -of lavf -lavfopts format=mov -ovc lavc -lavcopts vglobal=1:coder=0:vcodec=libx264:vbitrate=4000 -o testvid.mov