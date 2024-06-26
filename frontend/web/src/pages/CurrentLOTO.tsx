import styled from 'styled-components';
import * as Color from '@/config/color/Color.ts';
import { lockCheck } from '@/apis/Lock.ts';
// import { useEffect, useState } from 'react';
import { useRecoilValue } from 'recoil';
import { notificationEventsState } from '@/recoil/sseState.tsx';
import { useQuery } from '@tanstack/react-query';
interface ContentBoxProps {
  battery: number; // battery 속성에 대한 타입 정의
}
interface LockTypes {
  id: number;
  uid: string;
  locked: boolean;
  battery: number;
}

const BackGround = styled.div`
  width: 100%;
  height: auto;
  min-height: 100%;
  justify-content: center;
  display: flex;
`;
const Box = styled.div`
  width: 46.9375rem;
  height: 100%;
  display: flex;
  flex-direction: column;
  font-family: NYJGothicM;
`;

const TitleBox = styled.div`
  width: 100%;
  height: 4.25rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-sizing: border-box;
  background-color: white;
  position: sticky;
  top: 0rem;
  border-bottom: 2px solid ${Color.GRAY200};
`;
const Content = styled.div`
  width: 8.75rem;
  height: 1.5rem;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 1.25rem;
  font-weight: 500;
  text-overflow: ellipsis;
`;
const ContentBox = styled.div<ContentBoxProps>`
  width: 100%;
  height: 3.125rem;
  justify-content: space-between;
  align-items: center;
  /* padding: 0 1rem; */
  display: flex;
  flex-direction: row;
  box-sizing: border-box;
  background-color: ${(props) =>
    props.battery <= 10
      ? Color.RED1
      : props.battery <= 30
        ? Color.YELLOW100
        : null};
  border-bottom: 2px solid ${Color.GRAY200};
  /* color: ${(props) => (props.battery < 40 ? Color.WHITE : Color.BLACK)}; */
`;
const CurrentLOTO = () => {
  const events = useRecoilValue(notificationEventsState);
  const { data: locker } = useQuery({
    queryKey: ['locker', events],
    queryFn: () => lockCheck(),
  });

  return (
    <BackGround>
      <Box>
        <TitleBox>
          <Content style={{ fontSize: '1.5rem', fontWeight: '900' }}>
            No.
          </Content>
          <Content style={{ fontSize: '1.5rem', fontWeight: '900' }}>
            LOTO S/N
          </Content>
          <Content style={{ fontSize: '1.5rem', fontWeight: '900' }}>
            잠금 상태
          </Content>
          <Content style={{ fontSize: '1.5rem', fontWeight: '900' }}>
            배터리 잔량
          </Content>
        </TitleBox>
        {locker?.map((data: LockTypes) => (
          <ContentBox key={data.id} battery={data.battery}>
            <Content>{data.id}</Content>
            <Content>{data.uid}</Content>
            <Content>{data.locked ? 'LOCK' : 'UNLOCK'}</Content>
            <Content>{data.battery}%</Content>
          </ContentBox>
        ))}
      </Box>
    </BackGround>
  );
};

export default CurrentLOTO;
