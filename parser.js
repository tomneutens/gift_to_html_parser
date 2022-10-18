var peg = require("pegjs");
var fs = require('fs/promises');


async function parse(){
    const grammar = await fs.readFile('./grammars/gift_to_html_grammar.pegjs', 'utf8');
    console.log(grammar);
    const gift_sample = await fs.readFile("./gift_files/test_tf.gift", 'utf-8');
    console.log(gift_sample)
    let gift_html = parseString(grammar, gift_sample);
    console.log(gift_html);
    return gift_html;
}

function parseString(grammar, gift_string){
    var parser = peg.generate(grammar, {trace: false});
    var html = parser.parse(gift_string, {output: "source"});
    console.log("------------------------------------------");
    return html;
}

exports.parseString = parseString;


parse();