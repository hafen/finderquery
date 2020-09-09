import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';
import Slider from '@material-ui/core/Slider';

const useStyles = makeStyles({
  root: {
    width: 500,
    marginBottom: -12,
    marginTop: 10
  },
  label: {
    color: 'rgba(0, 0, 0, 0.54)'
    // textAlign: 'left'
  }
});

export default function RangeSlider({ value, setter }) {
  const classes = useStyles();

  const [val, setVal] = React.useState([-100, 100]);
  const handleChange = (event, newValue) => {
    setVal(newValue);
  };

  return (
    <div className={classes.root}>
      <Typography className={classes.label} id="range-slider" gutterBottom>
        {`Tonality [${val[0]},${val[1]}]`}
      </Typography>
      <Slider
        step={1}
        // marks
        min={-100}
        max={100}
        value={val}
        onChange={handleChange}
        onChangeCommitted={(event, newValue) => setter(newValue)}
        valueLabelDisplay="auto"
        aria-labelledby="range-slider"
      />
    </div>
  );
}