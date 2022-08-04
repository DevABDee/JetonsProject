const path = require('path');
const fs = require('fs');
const solc = require('solc');

const contractName = 'Lottery';
const contractFileName = contractName.toLocaleLowerCase() + '.sol';
const inboxPath = path.resolve(__dirname, 'contracts', contractFileName);
const source = fs.readFileSync(inboxPath, 'utf8');

// Wrapping the contract source to compile
var input = {
  language: 'Solidity',
  sources: {
    [contractFileName]: {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};

// Showing the compilation of the contract
const compiledContract = JSON.parse(solc.compile(JSON.stringify(input)));

module.exports = compiledContract.contracts[contractFileName][contractName];
