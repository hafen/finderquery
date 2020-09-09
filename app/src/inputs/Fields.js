import React from 'react';
// import { makeStyles } from '@material-ui/core/styles';
import FormGroup from '@material-ui/core/FormGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';
import { fields } from '../options.js';

export default function Fields({ update, selectedFields }) {

  const handleChange = (event) => {
    update(event.target.name);
  };
  
  return (
    <FormGroup row>
      {fields.map(d => (
        <FormControlLabel
          key={d}
          control={
            <Checkbox
              checked={selectedFields.indexOf(d) > -1}
              onChange={handleChange}
              name={d}
              color="primary"
            />
          }
          label={d}
        />
      ))}
    </FormGroup>
  );
}
