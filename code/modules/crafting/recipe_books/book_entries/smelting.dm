/datum/book_entry/smelting
	name = "Smelting Metal Ingots"
	category = "Smelting"

/datum/book_entry/smelting/inner_book_html(mob/user)
	return {"
		<p>Use a lit furnace to turn ore into bars. Hold the ore and right-click the furnace to load it. Right-click also loads coal or charcoal as an ingredient. Left-click with fuel when you want to refuel the furnace.</p>
		<p>Wait for the furnace to finish smelting, then click it with empty smithing tongs to retrieve the bars one at a time.</p>

		<h3>Ore to bars</h3>
		<p>Each piece of raw iron, copper, tin, silver, or gold makes one bar of the same metal. A stone furnace holds one piece at a time. An iron bloomery holds up to six.</p>

		<h3>Alloys</h3>
		<p>Load the full batch into the same furnace before it finishes smelting.</p>
		<table>
			<thead>
				<tr><th scope="col">Output</th><th scope="col">Ingredients</th><th scope="col">Furnace</th></tr>
			</thead>
			<tbody>
				<tr><td>4 bronze bars</td><td>3 raw copper or copper bars + 1 raw tin or tin bar</td><td>Bronze melter or great furnace</td></tr>
				<tr><td>4 steel bars</td><td>3 raw iron or iron bars + 1 coal or charcoal</td><td>Great furnace</td></tr>
				<tr><td>2 blacksteel bars</td><td>3 steel bars + 1 raw silver or silver bar</td><td>Great furnace</td></tr>
				<tr><td>4 gilbranze ingots</td><td>3 glimmering slag + 1 raw gold or gold bar</td><td>Great furnace</td></tr>
			</tbody>
		</table>

		<h3>Scrap slag</h3>
		<p>In a furnace with at least four slots, smelt 3 plain rocks and 1 piece of ore, coal, or salt together to make 4 lumps of scrap slag.</p>
	"}
