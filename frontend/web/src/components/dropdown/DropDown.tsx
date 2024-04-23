import React, { useState } from 'react';
import styled from 'styled-components';
import * as Color from '@/config/color/Color.tsx';
import useDetectClose from '@/hooks/UseDetectClose';
import Arrow from '/assets/icons/Arrow.svg';
import Select, { StylesConfig } from 'react-select';
interface OptionType {
  value: string;
  label: string;
}
interface DropDownProps {
  onClick: () => void;
}

const DropDownBox = styled.div`
  display: flex;
  width: 19.375rem;
  height: 3.75rem;
  padding: 1.125rem 0.9375rem;
  justify-content: center;
  align-items: center;
  border-radius: 0.625rem;
  border: 1px solid ${Color.GRAY300};
  background: ${Color.SNOW};
  box-shadow: 0px 4px 4px 0px rgba(0, 0, 0, 0.25);
`;
const DropDownContent = styled.div<DropDownProps>`
  width: 100%;
  height: 100%;
  justify-content: center;
  align-items: center;
  display: flex;
`;
const DropDownText = styled.div`
  font-size: 1.375rem;
  font-style: normal;
  font-weight: 700;
  line-height: normal;
`;
const DropDownArrow = styled.img`
  width: 1.5rem;
  height: 1.5rem;
`;
const StyledSelect = styled(Select).attrs({
  classNamePrefix: 'react-select',
})`
  .react-select__control {
    background-color: ${Color.SNOW};
    width: 17.5rem;
    height: 100%;
    /* padding-right: 15px; */
    border: none;
    /* border-radius: 20px; */
    display: flex;
    /* text-align: center; */
    font-size: 1.375rem;
    font-style: normal;
    font-weight: 700;
    line-height: normal;
    cursor: pointer;
  }
  .react-select__single-value {
    color: #ffffff; /* 텍스트 색상 지정 */
    font-size: 1.375rem;
    font-weight: 700;
  }
  .react-select__menu {
    background-color: #ffffff;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    font-weight: 600;
    text-align: center;
  }
  .react-select__option {
    background-color: transparent; /* option 배경색 */
    color: black; /* option 텍스트 색상 */
  }
  .react-select__option--is-selected {
    background-color: ${Color.SNOW}; /* 클릭된 option 배경색 */
    color: ${Color.GRAY300}; /* 클릭된 option 텍스트 색상 */
  }
  .react-select__option--is-focused {
    border: 1px solid #afaeb7;
    color: black; /* hover 상태의 option 텍스트 색상 */
  }
  .react-select__placeholder {
    color: ${Color.BLACK};
    font-weight: 600;
  }
`;
const Dropdown: React.FC = () => {
  const [isOpen, setIsOpen] = React.useState<boolean>(false);
  const [selectedOption, setSelectedOption] = useState<OptionType | null>(null);
  const onToggle = () => setIsOpen(!isOpen);
  //   const handleOptionChange = (option: ValueType<OptionType, false>) => {
  //     setSelectedOption(option as OptionType);
  //     setIsOpen(false);
  //   };
  const options: OptionType[] = [
    { value: '1공장', label: '1공장' },
    { value: '2공장', label: '2공장' },
    { value: '3공장', label: '3공장' },
    { value: '2공장', label: '2공장' },
    { value: '3공장', label: '3공장' },
    { value: '2공장', label: '2공장' },
    { value: '3공장', label: '3공장' },
    { value: '2공장', label: '2공장' },
    { value: '3공장', label: '3공장' },
    { value: '2공장', label: '2공장' },
    { value: '3공장', label: '3공장' },
  ];
  return (
    <DropDownBox>
      {/* <DropDownContent onClick={onToggle}></DropDownContent>
       */}
      <StyledSelect
        options={options}
        // onChange={handleOptionChange} // 옵션 선택 시 처리
        menuIsOpen={isOpen} // 드롭다운 메뉴의 개폐 상태
        placeholder="공장선택"
        onMenuOpen={() => setIsOpen(true)}
        onMenuClose={() => setIsOpen(false)}
        value={selectedOption}
        // getOptionLabel={(option) => option.label}
        // getOptionValue={(option) => option.value}
      />
    </DropDownBox>
  );
};

export default Dropdown;