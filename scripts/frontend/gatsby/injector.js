const fs = require('fs');

try {
	const b = fs.readFileSync('secrets.json');
	const j = JSON.parse(b);

	Object.keys(j).forEach(function (key) {
		if (!process.env.hasOwnProperty(key)) {
			process.env[key] = j[key];
		} else {
			console.log(`${key} was already there ...`);
		}
	});

} catch(e) {
	console.log(`could not set env. variables: ${e.message}`);
}
