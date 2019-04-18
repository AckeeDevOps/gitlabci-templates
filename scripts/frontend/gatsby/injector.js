const fs = require('fs');

try {
	const b = fs.readFileSync('secrets.json');
	const j = JSON.parse(b);

	Object.keys(j).forEach(function (key) {
		process.env[key] = j[key];
	});

} catch(e) {
	console.log(`could not set env. variables: ${e.message}`);
}
